import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:igplayer/manage/igplayer_controller.dart';
import 'package:igplayer/manage/video_player_bridge.dart';

class IgVideoPlayer extends StatefulWidget {
  const IgVideoPlayer({
    required this.videoUrl,
    required this.igPlayerController,
    this.autoPlay = false,
    this.artworkUrl = "",
    this.title = "IgPlayer",
    this.subTitle = "Something Playing",
    this.initialPosition = 0,
    this.volume = 1.0,
    Key? key,
  }) : super(key: key);
  final String videoUrl;
  final IgPlayerController igPlayerController;
  final bool autoPlay;
  final String artworkUrl;
  final String title;
  final String subTitle;
  final int initialPosition;
  final double volume;
  @override
  State<IgVideoPlayer> createState() => _IgVideoPlayerState();
}

class _IgVideoPlayerState extends State<IgVideoPlayer> {
  late VideoPlayerBridge videoPlayerBridge;
  @override
  void initState() {
    super.initState();
    videoPlayerBridge = VideoPlayerBridge(widget.igPlayerController);
    widget.igPlayerController.initBridge(videoPlayerBridge);
  }

  @override
  Widget build(BuildContext context) {
    return nativeViewManager();
  }

  Widget nativeViewManager() {
    if (Platform.isAndroid) {
      return androidView();
    } else {
      return iosView();
    }
  }

  @override
  void dispose() {
    videoPlayerBridge.dispose();
    super.dispose();
  }

  Widget androidView() {
    return AndroidView(
      viewType: 'igzafer/IgVideoPlayerNative',
      creationParams: {
        "url": widget.videoUrl,
        "autoPlay": widget.autoPlay,
        "artworkUrl": widget.artworkUrl,
        "title": widget.title,
        "subtitle": widget.subTitle,
        "initialPosition": widget.initialPosition,
      },
      onPlatformViewCreated: (id) {
        videoPlayerBridge.listenPlayerEvents();
      },
      creationParamsCodec: const JSONMessageCodec(),
    );
  }

  @override
  void didUpdateWidget(covariant IgVideoPlayer oldWidget) {
    debugPrint("test ${oldWidget.volume} : ${widget.volume}");

    if (oldWidget.videoUrl != widget.videoUrl) {
      _mediaChanged();
    }

    super.didUpdateWidget(oldWidget);
  }

  Widget iosView() {
    return UiKitView(
      viewType: 'igzafer/IgVideoPlayerNative',
      creationParams: {
        "url": widget.videoUrl,
        "autoPlay": widget.autoPlay,
        "artworkUrl": widget.artworkUrl,
        "title": widget.title,
        "subtitle": widget.subTitle,
        "initialPosition": widget.initialPosition,
        "volume": widget.volume,
      },
      onPlatformViewCreated: (id) {
        videoPlayerBridge.listenPlayerEvents();
      },
      creationParamsCodec: const JSONMessageCodec(),
    );
  }

  void _mediaChanged() {
    videoPlayerBridge.mediaChanged(
        widget.videoUrl, widget.title, widget.subTitle, widget.artworkUrl, widget.autoPlay, widget.volume);
  }
}
