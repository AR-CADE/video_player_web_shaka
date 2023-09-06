// ignore_for_file: unused_local_variable

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_web_shaka/shaka.dart' as shaka;

void main() {
  runApp(const VideoApp());
}

class VideoApp extends StatefulWidget {
  const VideoApp({super.key});

  @override
  VideoAppState createState() => VideoAppState();
}

class VideoAppState extends State<VideoApp> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    shaka.configure(<String, Object>{'streaming.autoLowLatencyMode': true});

    final uri0 = Uri.parse(
      'https://cfd-v4-service-channel-stitcher-use1-1.prd.pluto.tv/stitch/hls/channel/6304f20c941c5d00089634e7/master.m3u8?advertisingId&appName=web&terminate=false&appVersion=1&architecture&buildVersion&clientTime&deviceDNT=false&deviceId=d2ac77c8-fa01-4393-b7db-7560473c8809&deviceLat=0&deviceLon=0&deviceMake=flutter&deviceModel=web&deviceType=web&deviceVersion=flutter_current_version&includeExtendedEvents=false&marketingRegion=EARTH&country=EARTH&serverSideAds=false&sid=987b6e06-c93b-412c-a8f3-12bcf7dee920&clientID=d2ac77c8-fa01-4393-b7db-7560473c8809&clientModelNumber=1.0.0&clientDeviceType=0&sessionID&userId',
    );
    final uri = Uri.parse(
      'https://livesim.dashif.org/livesim/chunkdur_1/ato_7/testpic4_8s/Manifest.mpd',
    );
    final uri1 = Uri.parse(
      'https://dash.akamaized.net/dash264/TestCasesUHD/2b/11/MultiRate.mpd',
    );
    final uri2 = Uri.parse(
      'https://dash.akamaized.net/dash264/TestCasesIOP33/adapatationSetSwitching/5/manifest.mpd',
    );
    final uri3 = Uri.parse(
      'https://dash.akamaized.net/dash264/TestCases/2c/qualcomm/1/MultiResMPEG2.mpd',
    );
    final uri4 = Uri.parse(
      'https://dash.akamaized.net/dash264/TestCasesHD/2b/qualcomm/1/MultiResMPEG2.mpd',
    );
    final uri5 = Uri.parse(
      'https://dash.akamaized.net/dash264/TestCases/1b/qualcomm/1/MultiRatePatched.mpd',
    );
    final uri6 = Uri.parse(
      'https://bitmovin-a.akamaihd.net/content/MI201109210084_1/mpds/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.mpd',
    );

    final uri7 = Uri.parse(
      'https://cmafref.akamaized.net/cmaf/live-ull/2006350/akambr/out.mpd',
    );
    final uri8 = Uri.parse(
      'http://media.developer.dolby.com/DolbyVision_Atmos/profile8.1_DASH/p8.1.mpd',
    );
    final uri9 = Uri.parse(
      'https://ftp.itec.aau.at/datasets/mmsys12/TheSwissAccount/MPDs/TheSwissAccount_15s_isoffmain_DIS_23009_1_v_2_1c2_2011_08_30.mpd',
    );
    final uri10 = Uri.parse(
      'https://ftp.itec.aau.at/datasets/mmsys12/RedBullPlayStreets/MPDs/RedBullPlayStreets_15s_isoffmain_DIS_23009_1_v_2_1c2_2011_08_30.mpd',
    );
    final uri11 = Uri.parse(
      'https://ftp.itec.aau.at/datasets/mmsys12/Valkaama/MPDs/Valkaama_15s_act_isoffmain_DIS_23009_1_v_2_1c2_2011_08_30.mpd',
    );
    final uri12 = Uri.parse(
      'https://ftp.itec.aau.at/datasets/mmsys12/OfForestAndMen/MPDs/OfForestAndMen_15s_isoffmain_DIS_23009_1_v_2_1c2_2011_08_30.mpd',
    );
    final uri13 = Uri.parse(
      'https://ftp.itec.aau.at/datasets/mmsys12/TearsOfSteel/ToS_s2.mpd',
    );

    final uri14 = Uri.parse(
      'http://vjs.zencdn.net/v/oceans.mp4',
    );
    final uri15 = Uri.parse(
      'https://diceyk6a7voy4.cloudfront.net/e78752a1-2e83-43fa-85ae-3d508be29366/hls/fitfest-sample-1_Ott_Hls_Ts_Avc_Aac_16x9_1280x720p_30Hz_6.0Mbps_qvbr.m3u8',
    );
    final uri16 = Uri.parse(
      'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
    );
    final uri17 = Uri.parse(
      'https://res.cloudinary.com/dannykeane/video/upload/sp_full_hd/q_80:qmax_90,ac_none/v1/dk-memoji-dark.m3u8',
    );
    final uri18 = Uri.parse(
      'https://d1gnaphp93fop2.cloudfront.net/videos/multiresolution/rendition_new10.m3u8',
    );
    final uri19 = Uri.parse(
      'https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8',
    );
    final uri20 = Uri.parse(
      'http://qthttp.apple.com.edgesuite.net/1010qwoeiuryfg/sl.m3u8',
    );

    final uri21 = Uri.parse(
      'http://walterebert.com/playground/video/hls/sintel-trailer.m3u8',
    );
    final uri22 = Uri.parse(
      'http://content.jwplatform.com/manifests/vM7nH0Kl.m3u8',
    );

    final uri23 = Uri.parse(
      'http://cdn-fms.rbs.com.br/vod/hls_sample1_manifest.m3u8',
    );
    final uri24 = Uri.parse(
      'http://playertest.longtailvideo.com/adaptive/wowzaid3/playlist.m3u8',
    );
    final uri25 = Uri.parse(
      'http://sample.vodobox.net/skate_phantom_flex_4k/skate_phantom_flex_4k.m3u8',
    );

    final uri26 = Uri.parse(
      'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8',
    );
    final uri27 = Uri.parse(
      'https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8',
    );
    final uri28 = Uri.parse(
      'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.mp4/.m3u8',
    );
    final uri29 = Uri.parse(
      'https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/master.m3u8',
    );
    final uri30 = Uri.parse(
      'https://assets.afcdn.com/video49/20210722/v_645516.m3u8',
    );
    final uri31 = Uri.parse(
      'http://amssamples.streaming.mediaservices.windows.net/91492735-c523-432b-ba01-faba6c2206a2/AzureMediaServicesPromo.ism/manifest(format=m3u8-aapl)',
    );

    try {
      _controller = VideoPlayerController.networkUrl(
        uri0,
        httpHeaders: <String, String>{'test': 'test'},
      )..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized,
          // even before the play button has been pressed.
          setState(() {});
        });
      _controller.setVolume(0);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      home: Scaffold(
        body: Center(
          child: _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : Container(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            });
          },
          child: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
