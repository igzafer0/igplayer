import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:igplayer/manage/igplayer_controller.dart';

class VideoPlayerBridge {
  final IgPlayerController controller;
  late MethodChannel methodChannel;
  late EventChannel eventChannel;
  VideoPlayerBridge(this.controller) {
    _listenPlayerEvents();
    methodChannel = const MethodChannel("igzafer/NativeVideoPlayerMethodChannel");
    play();
  }

  void mediaChanged(String videoUrl) {
    methodChannel.invokeMethod("mediaChanged", {"url": videoUrl});
  }

  void newPosition(int newPosition) {
    methodChannel.invokeMethod("newPosition", newPosition);
  }

  void skip(int skipPosition) {
    methodChannel.invokeMethod("skipPosition", skipPosition);
  }

  void play() {
    methodChannel.invokeMethod("play");
  }

  void pause() {
    methodChannel.invokeMethod("pause");
  }

  Future<void> _listenPlayerEvents() async {
    eventChannel = const EventChannel("igzafer/NativeVideoPlayerEventChannel", JSONMethodCodec());
    eventChannel.receiveBroadcastStream([]).listen(_listenEvents);
  }

  void _listenEvents(dynamic event) async {
    switch (event["name"]) {
      case "playerTime":
        controller.playerTimeListener.add(event["time"]);
        break;
      case "playerDuration":
        controller.playerDuration = event["duration"];
        break;
    }
  }
}
