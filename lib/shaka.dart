/// shaka library
library shaka;

import 'package:video_player_web_shaka/video_player_web_shaka.dart';

void configure(Map<String, Object> options) {
  VideoPlayerPluginShaka.options = options;
}
