@JS()
library shaka.js;

import 'dart:html' show CanvasElement, VideoElement;

import 'package:js/js.dart';

@JS('shaka')
class Shaka {
  @JS()
  // ignore: non_constant_identifier_names
  external static ShakaPlayer Player;

  external static ShakaPolyfill polyfill;
}

@JS('shaka.Player')
class ShakaPlayer {
  @JS()
  external factory ShakaPlayer(VideoElement? video);

  @JS()
  external bool isBrowserSupported();

  @JS()
  external Future<void> load(String videoSrc);

  @JS()
  external Future<void> unload();

  @JS()
  external Future<void> attach(VideoElement video);

  @JS()
  external bool configure(Map<String, dynamic> config);

  @JS()
  external void attachCanvas(CanvasElement canvas);

  @JS()
  external Future<void> destroy();

  @JS()
  external NetworkEngine getNetworkingEngine();

  @JS()
  external void addEventListener(
    String event,
    Function callback,
  );

  @JS()
  external void removeEventListener(
    String event,
    Function callback,
  );

  @JS()
  external Future<void> detach();
}

@JS('shaka.polyfill')
class ShakaPolyfill {
  @JS()
  external void installAll();
}

@JS()
class NetworkEngine {
  @JS()
  external Future<void> registerRequestFilter(Function filter);
}

@JS()
class ShakaHttpRequest {
  @JS()
  external Object headers;

  @JS()
  external bool allowCrossSiteCredentials;
}

@JS()
class ShakaError {
  /// see https://shaka-player-demo.appspot.com/docs/api/shaka.util.Error.html#.Code
  @JS()
  external int get code;

  /// see https://shaka-player-demo.appspot.com/docs/api/shaka.util.Error.html#.Severity
  @JS()
  external int get severity;

  /// see https://shaka-player-demo.appspot.com/docs/api/shaka.util.Error.html#.Category
  @JS()
  external int get category;

  @JS()
  external Object get varArgs;
}
