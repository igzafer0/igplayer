// ignore_for_file: constant_identifier_names, camel_case_types

import 'dart:async';
import 'package:igplayer/manage/video_player_bridge.dart';

class IgPlayerController {
  StreamController<int> playerTimeListener = StreamController<int>();
  int playerDuration = 0;
  // ignore: non_constant_identifier_names
  StreamController<bool> isPlaying = StreamController<bool>();

  late VideoPlayerBridge _bridge;
  IgPlayerController() {
    playerTimeListener.add(0);
  }

  initBridge(VideoPlayerBridge bridge) {
    _bridge = bridge;
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

  void play() {
    _bridge.play();
  }

  void pause() {
    _bridge.pause();
  }

  ///1.0 is default speed 2.0 is 2x speed and 0.25 is 0.25 speed.
  ///No difference between negative or positive value
  void changeSpeed(double speed) {
    _bridge.changeSpeed(speed);
  }

  void changeVolume(double volume) {
    _bridge.changeVolume(volume);
  }

  ///only ios, turn on or off pip mode
  void enablePip(bool enablePip) {
    _bridge.enablePip(enablePip);
  }

  ///dont forget
  void dispose() {
    _bridge.dispose();
  }
}
