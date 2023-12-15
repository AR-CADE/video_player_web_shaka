// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:html' as html;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:js/js_util.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:video_player_web_shaka/no_script_tag_exception.dart';
import 'package:video_player_web_shaka/shaka_js.dart';
import 'package:video_player_web_shaka/src/duration_utils.dart';

// An error code value to error name Map.
// See: https://developer.mozilla.org/en-US/docs/Web/API/MediaError/code
const Map<int, String> _kErrorValueToErrorName = <int, String>{
  1: 'MEDIA_ERR_ABORTED',
  2: 'MEDIA_ERR_NETWORK',
  3: 'MEDIA_ERR_DECODE',
  4: 'MEDIA_ERR_SRC_NOT_SUPPORTED',
};

// An error code value to description Map.
// See: https://developer.mozilla.org/en-US/docs/Web/API/MediaError/code
const Map<int, String> _kErrorValueToErrorDescription = <int, String>{
  1: 'The user canceled the fetching of the video.',
  // ignore: lines_longer_than_80_chars
  2: 'A network error occurred while fetching the video, despite having previously been available.',
  // ignore: lines_longer_than_80_chars
  3: 'An error occurred while trying to decode the video, despite having previously been determined to be usable.',
  // ignore: lines_longer_than_80_chars
  4: 'The video has been found to be unsuitable (missing or in a format not supported by your browser).',
  5: 'Could not load manifest',
};

// The default error message, when the error is an empty string
// See: https://developer.mozilla.org/en-US/docs/Web/API/MediaError/message
const String _kDefaultErrorMessage =
    'No further diagnostic information can be determined or provided.';

/// Wraps a [html.VideoElement] so its API complies with what is
/// expected by the plugin.
class VideoPlayer {
  /// Create a [VideoPlayer] from a [html.VideoElement] instance.
  VideoPlayer({
    required html.VideoElement videoElement,
    required String uri,
    required Map<String, String> headers,
    Map<String, dynamic>? config,
    @visibleForTesting StreamController<VideoEvent>? eventController,
  })  : _videoElement = videoElement,
        _eventController = eventController ?? StreamController<VideoEvent>(),
        _uri = uri,
        _headers = headers,
        _config = config;

  final StreamController<VideoEvent> _eventController;
  final html.VideoElement _videoElement;
  final String _uri;
  final Map<String, String> _headers;
  final Map<String, dynamic>? _config;

  bool _isInitialized = false;
  bool _isBuffering = false;
  ShakaPlayer? _shaka;

  void Function(ShakaError) get onError => allowInterop((ShakaError e) {
        if (e.severity == 2) {
          /// Critical error
          _eventController.addError(
            PlatformException(
              code: _kErrorValueToErrorName[2]!,
              message:
                  // ignore: lines_longer_than_80_chars
                  'Critical error that the library cannot recover from. These usually cause the Player to stop loading or updating. A new manifest must be loaded to reset the library.',
              details: 'shaka-player error code: ${e.code}',
            ),
          );
        }
      });

  /// Returns the [Stream] of [VideoEvent]s from the inner [html.VideoElement].
  Stream<VideoEvent> get events => _eventController.stream;

  /// Initializes the wrapped [html.VideoElement].
  ///
  /// This method sets the required DOM attributes so videos can
  /// [play] programmatically, and attaches listeners to the internal events
  /// from the [html.VideoElement] to react to them / expose them through the
  /// [VideoPlayer.events] stream.
  Future<void> initialize() async {
    _videoElement
      ..autoplay = false
      ..controls = false

      // Allows Safari iOS to play the video inline
      ..setAttribute('playsinline', 'true')

      // Set autoplay to false since most browsers won't autoplay a video unless
      // it is muted
      ..setAttribute('autoplay', 'false');

    if (await _shouldUseShakaLibrary()) {
      try {
        _shaka = ShakaPlayer(null);

        if (_config != null) {
          _shaka!.configure(_config!);
        }

        await _shaka!.getNetworkingEngine().registerRequestFilter(
          allowInterop((_, ShakaHttpRequest request, __) {
            if (_headers.isEmpty) {
              return request;
            }

            _headers.forEach((String key, String value) {
              if (key != 'useCookies') {
                setProperty<String>(request.headers, key, value);
              } else {
                request.allowCrossSiteCredentials = true;
              }
            });

            return request;
          }),
        );

        _shaka!.addEventListener(
          'error',
          onError,
        );

        _videoElement.onCanPlay.listen((_) {
          if (!_isInitialized) {
            _isInitialized = true;
            _sendInitialized();
          }
          setBuffering(false);
        });

        await _shaka!.attach(_videoElement);
        await _shaka!.load(_uri);
      } catch (e) {
        throw NoScriptTagException();
      }
    } else {
      _videoElement
        ..src = _uri
        ..addEventListener('durationchange', _durationChange);
    }

    _videoElement.onCanPlayThrough.listen((_) {
      setBuffering(false);
    });

    _videoElement.onPlaying.listen((_) {
      setBuffering(false);
    });

    _videoElement.onWaiting.listen((_) {
      setBuffering(true);
      _sendBufferingRangesUpdate();
    });

    // The error event fires when some form of error occurs while attempting to
    // load or perform the media.
    _videoElement.onError.listen((_) {
      setBuffering(false);
      // The Event itself (_) doesn't contain info about the actual error.
      // We need to look at the HTMLMediaElement.error.
      // See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLMediaElement/error
      final error = _videoElement.error!;
      _eventController.addError(
        PlatformException(
          code: _kErrorValueToErrorName[error.code]!,
          message: error.message != '' ? error.message : _kDefaultErrorMessage,
          details: _kErrorValueToErrorDescription[error.code],
        ),
      );
    });

    _videoElement.onEnded.listen((_) {
      setBuffering(false);
      _eventController.add(VideoEvent(eventType: VideoEventType.completed));
    });
  }

  void _durationChange(_) {
    if (_videoElement.duration == 0) {
      return;
    }
    if (!_isInitialized) {
      _isInitialized = true;
      _sendInitialized();
    }
  }

  /// Attempts to play the video.
  ///
  /// If this method is called programmatically (without user interaction), it
  /// might fail unless the video is completely muted
  /// (or it has no Audio tracks).
  ///
  /// When called from some user interaction (a tap on a button), the above
  /// limitation should disappear.
  Future<void> play() {
    return _videoElement.play().catchError(
      (Object e) {
        // play() attempts to begin playback of the media. It returns
        // a Promise which can get rejected in case of failure to begin
        // playback for any reason, such as permission issues.
        // The rejection handler is called with a DomException.
        // See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLMediaElement/play
        final exception = e as html.DomException;
        _eventController.addError(
          PlatformException(
            code: exception.name,
            message: exception.message,
          ),
        );
      },
      test: (Object e) => e is html.DomException,
    );
  }

  /// Pauses the video in the current position.
  void pause() {
    _videoElement.pause();
  }

  /// Controls whether the video should start again after it finishes.
  // ignore: use_setters_to_change_properties, avoid_positional_boolean_parameters
  void setLooping(bool value) {
    _videoElement.loop = value;
  }

  /// Sets the volume at which the media will be played.
  ///
  /// Values must fall between 0 and 1, where 0 is muted and 1 is the loudest.
  ///
  /// When volume is set to 0, the `muted` property is also applied to the
  /// [html.VideoElement]. This is required for auto-play on the web.
  void setVolume(double volume) {
    assert(volume >= 0 && volume <= 1, 'Volume must be between 0 and 1');

    // TODO(ditman): Do we need to expose a "muted" API?
    // https://github.com/flutter/flutter/issues/60721
    _videoElement
      ..muted = !(volume > 0.0)
      ..volume = volume;
  }

  /// Sets the playback `speed`.
  ///
  /// A `speed` of 1.0 is "normal speed," values lower than 1.0 make the media
  /// play slower than normal, higher values make it play faster.
  ///
  /// `speed` cannot be negative.
  ///
  /// The audio is muted when the fast forward or slow motion is
  /// outside a useful range
  /// (for example, Gecko mutes the sound outside the range 0.25 to 4.0).
  ///
  /// The pitch of the audio is corrected by default.
  void setPlaybackSpeed(double speed) {
    assert(speed > 0, 'Speed must be higher than 0');

    _videoElement.playbackRate = speed;
  }

  /// Moves the playback head to a new `position`.
  ///
  /// `position` cannot be negative.
  void seekTo(Duration position) {
    assert(!position.isNegative, 'Seek `position` cannot be negative');

    _videoElement.currentTime = position.inMilliseconds.toDouble() / 1000;
  }

  /// Returns the current playback head position as a [Duration].
  Duration getPosition() {
    _sendBufferingRangesUpdate();
    return Duration(milliseconds: (_videoElement.currentTime * 1000).round());
  }

  /// Disposes of the current [html.VideoElement].
  void dispose() {
    _shaka!.removeEventListener(
      'error',
      onError,
    );
    _videoElement
      ..removeEventListener('durationchange', _durationChange)
      ..removeAttribute('src')
      ..load();
    _shaka?.destroy();
  }

  // Sends an [VideoEventType.initialized] [VideoEvent] with info about the
  // wrapped video.
  void _sendInitialized() {
    final duration =
        convertNumVideoDurationToPluginDuration(_videoElement.duration);

    final size = _videoElement.videoHeight.isFinite
        ? Size(
            _videoElement.videoWidth.toDouble(),
            _videoElement.videoHeight.toDouble(),
          )
        : null;

    _eventController.add(
      VideoEvent(
        eventType: VideoEventType.initialized,
        duration: duration,
        size: size,
      ),
    );
  }

  /// Caches the current "buffering" state of the video.
  ///
  /// If the current buffering state is different from the previous one
  /// ([_isBuffering]), this dispatches a [VideoEvent].
  @visibleForTesting
  // ignore: avoid_positional_boolean_parameters
  void setBuffering(bool buffering) {
    if (_isBuffering != buffering) {
      _isBuffering = buffering;
      _eventController.add(
        VideoEvent(
          eventType: _isBuffering
              ? VideoEventType.bufferingStart
              : VideoEventType.bufferingEnd,
        ),
      );
    }
  }

  // Broadcasts the [html.VideoElement.buffered] status through the [events]
  // stream.
  void _sendBufferingRangesUpdate() {
    _eventController.add(
      VideoEvent(
        buffered: _toDurationRange(_videoElement.buffered),
        eventType: VideoEventType.bufferingUpdate,
      ),
    );
  }

  // Converts from [html.TimeRanges] to our own List<DurationRange>.
  List<DurationRange> _toDurationRange(html.TimeRanges buffered) {
    final durationRange = <DurationRange>[];
    for (var i = 0; i < buffered.length; i++) {
      durationRange.add(
        DurationRange(
          Duration(milliseconds: (buffered.start(i) * 1000).round()),
          Duration(milliseconds: (buffered.end(i) * 1000).round()),
        ),
      );
    }
    return durationRange;
  }

  bool _canPlayDashNatively() {
    return false;
  }

  bool _canPlayHlsNatively() {
    try {
      final canPlayType =
          _videoElement.canPlayType('application/vnd.apple.mpegurl');
      return canPlayType != '';
    } catch (e) {
      return false;
    }
  }

  bool _canPlayMss() {
    return false;
  }

  Future<bool> _shouldUseShakaLibrary() async {
    if (!_isShakaSupported) {
      return false;
    }

    if (_isDash) {
      if (_canPlayDashNatively()) {
        return false;
      }
      return true;
    }

    if (_isHls) {
      if (_canPlayHlsNatively()) {
        return false;
      }
      return true;
    }

    if (_isMss) {
      if (_canPlayMss()) {
        return false;
      }
      return true;
    }

    return _testIfHlsOrMpd();
  }

  bool get _isHls => _uri.toLowerCase().contains('m3u8');

  bool get _isDash =>
      _uri.toLowerCase().contains('mpd') ||
      _uri.toLowerCase().contains('manifest');

  bool get _isMss => _uri.toLowerCase().contains('ism');

  bool get _isShakaSupported => Shaka.Player.isBrowserSupported();

  Future<bool> _testIfHlsOrMpd() async {
    try {
      final headers = Map<String, String>.of(_headers);
      if (headers.containsKey('Range') || headers.containsKey('range')) {
        final range = (headers['Range'] ?? headers['range'])!
            .split('bytes')[1]
            .split('-')
            .map(int.parse)
            .toList();
        range[1] = min(range[0] + 1023, range[1]);
        headers['Range'] = 'bytes=${range[0]}-${range[1]}';
      } else {
        headers['Range'] = 'bytes=0-1023';
      }
      final response = await http.get(Uri.parse(_uri), headers: headers);
      final body = response.body;

      if (_isHlsBody(body) || _isDashBody(body) || _isMssBody(body)) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  bool _isHlsBody(String body) => body.contains('#EXTM3U');

  bool _isDashBody(String body) =>
      body.startsWith('<?xml') && body.contains('<MPD');

  bool _isMssBody(String body) =>
      body.startsWith('<?xml') && body.contains('<SmoothStreamingMedia');
}
