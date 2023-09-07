/// shaka library
library shaka;

import 'package:video_player_web_shaka/video_player_web_shaka.dart';
export 'package:video_player_web_shaka/shaka_js.dart';

void configure(Map<String, dynamic> config) {
  VideoPlayerPluginShaka.config = config;
}
