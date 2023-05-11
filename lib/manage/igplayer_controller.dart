import 'dart:async';
import 'package:igplayer/manage/video_player_bridge.dart';

class IgPlayerController {
  StreamController<int> playerTimeListener = StreamController<int>();
  int playerDuration = 0;

  late VideoPlayerBridge bridge;
  IgPlayerController() {
    playerTimeListener.add(0);
  }

  initBridge(VideoPlayerBridge bridge) {
    this.bridge = bridge;
  }

  ///Updates your player position with `newPosition`
  ///
  ///For example:
  ///```dart
  ///igPlayercontroller.newPosition(1)
  /// ```
  /// And that's it. Your player will now jump to the first second.
  void newPosition(int newPosition) {
    bridge.newPosition(newPosition);
  }

  ///It will skip forward or backward by the given parameter.
  ///
  ///For example:
  ///```dart
  ///igPlayercontroller.skip(-1)
  /// ```
  ///It will go back by 1 second.
  void skip(int skipPosition) {
    bridge.skip(skipPosition);
  }

  void play() {
    bridge.play();
  }

  void pause() {
    bridge.pause();
  }

  ///This is a very funny method. You can change the video speed but...
  ///
  ///But if you send negative value, the video starts to rewind
  ///
  ///1.0 is default speed 2.0 is 2x speed and 0.25 is 0.25 speed.
  void changeSpeed(double speed) {
    bridge.changeSpeed(speed);
  }
}
