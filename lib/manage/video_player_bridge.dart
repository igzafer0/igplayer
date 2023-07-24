import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:igplayer/manage/igplayer_controller.dart';

class VideoPlayerBridge {
  final IgPlayerController controller;
  late MethodChannel methodChannel;
  late EventChannel eventChannel;
  VideoPlayerBridge(this.controller, viewId) {
    methodChannel = MethodChannel("igzafer/NativeVideoPlayerMethodChannel$viewId");
  }

  void mediaChanged(String videoUrl, String title, String subtitle, String artworkUrl, bool autoPlay, double volume) {
    methodChannel.invokeMethod("mediaChanged", {
      "url": videoUrl,
      "title": title,
      "subtitle": subtitle,
      "artworkUrl": artworkUrl,
      "autoPlay": autoPlay,
      "volume": volume
    });
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

  void changeSpeed(double speed) {
    methodChannel.invokeMethod("changeSpeed", speed);
  }

  void changeVolume(double volume) {
    methodChannel.invokeMethod("changeVolume", volume);
  }

  void enablePip(bool enablePip) {
    methodChannel.invokeMethod("enablePip", enablePip);
  }

  void dispose() {
    methodChannel.invokeMethod("dispose");
  }

  Future<void> listenPlayerEvents(id) async {
    eventChannel = EventChannel("igzafer/NativeVideoPlayerEventChannel$id", const JSONMethodCodec());
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
      case "isPlaying":
        controller.isPlaying.add(event["state"]);
        break;
    }
  }
}
