import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:igplayer/manage/igplayer_controller.dart';
import 'package:igplayer/manage/video_player_bridge.dart';

class IgVideoPlayer extends StatefulWidget {
  const IgVideoPlayer({required this.videoUrl, required this.igPlayerController, Key? key}) : super(key: key);
  final String videoUrl;
  final IgPlayerController igPlayerController;
  @override
  State<IgVideoPlayer> createState() => _IgVideoPlayerState();
}

class _IgVideoPlayerState extends State<IgVideoPlayer> {
  VideoPlayerBridge? videoPlayerBridge;
  @override
  void initState() {
    super.initState();
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

  Widget androidView() {
    return AndroidView(
      viewType: 'igzafer/IgVideoPlayerNative',
      creationParams: {
        "url": widget.videoUrl,
      },
      onPlatformViewCreated: (id) {
        videoPlayerBridge ??= VideoPlayerBridge(widget.igPlayerController);
      },
      creationParamsCodec: const JSONMessageCodec(),
    );
  }

  @override
  void didUpdateWidget(covariant IgVideoPlayer oldWidget) {
    if (oldWidget.videoUrl != widget.videoUrl) {
      _mediaChanged();
    }

    super.didUpdateWidget(oldWidget);
  }

  Widget iosView() {
    debugPrint("çalıştım ${widget.videoUrl}");

    return UiKitView(
      viewType: 'igzafer/IgVideoPlayerNative',
      creationParams: {
        "url": widget.videoUrl,
      },
      onPlatformViewCreated: (id) {
        videoPlayerBridge ??= VideoPlayerBridge(widget.igPlayerController);
      },
      creationParamsCodec: const JSONMessageCodec(),
    );
  }

  void _mediaChanged() {
    videoPlayerBridge?.mediaChanged(widget.videoUrl);
  }
}
