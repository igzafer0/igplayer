import 'dart:async';

import 'package:igplayer/manage/video_player_bridge.dart';

class IgPlayerController {
  StreamController<int> playerTimeListener = StreamController<int>();

  late VideoPlayerBridge _bridge;
  IgPlayerController() {
    _bridge = VideoPlayerBridge(this);
  }

  ///Updates your player position with `newPosition`
  ///
  ///For example:
  ///```dart
  ///igPlayercontroller.newPosition(1)
  /// ```
  /// And that's it. Your player will now jump to the first second.
  void newPosition(int newPosition) {
    _bridge.newPosition(newPosition);
  }

  ///It will skip forward or backward by the given parameter.
  ///
  ///For example:
  ///```dart
  ///igPlayercontroller.skip(-1)
  /// ```
  ///It will go back by 1 second.
  void skip(int skipPosition) {
    _bridge.skip(skipPosition);
  }
}
