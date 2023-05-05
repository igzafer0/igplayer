import 'dart:async';

import 'package:igplayer/manage/video_player_bridge.dart';

class IgPlayerController {
  StreamController<int> playerTimeListener = StreamController<int>();

  ///Updates your player position with `newPosition`
  ///
  ///For example:
  ///```dart
  ///igPlayercontroller.newPosition(1)
  /// ```
  /// And that's it. Your player will now skip to the first second.
  void newPosition(int newPosition) {
    VideoPlayerBridge(this).newPosition(newPosition);
  }
}
