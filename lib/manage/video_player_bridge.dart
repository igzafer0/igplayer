import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:igplayer/manage/igplayer_controller.dart';

class VideoPlayerBridge {
  final IgPlayerController controller;

  VideoPlayerBridge(this.controller) {
    _listenPlayerEvents();
    MethodChannel methodChannel = const MethodChannel("igzafer/NativeVideoPlayerMethodChannel");
    methodChannel.invokeMethod("play");
  }

  newPosition(int newPosition) {
    MethodChannel methodChannel = const MethodChannel("igzafer/NativeVideoPlayerMethodChannel");
    methodChannel.invokeMethod("newPosition", newPosition);
  }

  Future<void> _listenPlayerEvents() async {
    EventChannel eventChannel = const EventChannel("igzafer/NativeVideoPlayerEventChannel", JSONMethodCodec());
    eventChannel.receiveBroadcastStream([]).listen(_listenEvents);
  }

  void _listenEvents(dynamic event) async {
    //playerTime.add(event["playerTime"]);
    switch (event["name"]) {
      case "playerTime":
        controller.playerTimeListener.add(event["time"]);
    }
  }
}
