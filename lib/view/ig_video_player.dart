import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IgVideoPlayer extends StatefulWidget {
  const IgVideoPlayer({required this.videoUrl, Key? key}) : super(key: key);
  final String videoUrl;
  @override
  State<IgVideoPlayer> createState() => _IgVideoPlayerState();
}

class _IgVideoPlayerState extends State<IgVideoPlayer> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: () {}, child: nativeViewManager());
  }

  Widget nativeViewManager() {
    if (Platform.isAndroid) {
      return androidView();
    } else {
      return Container();
    }
  }

  Widget androidView() {
    return AndroidView(
      viewType: 'igzafer/IgVideoPlayerNative',
      creationParams: {
        "url": widget.videoUrl,
      },
      creationParamsCodec: const JSONMessageCodec(),
      onPlatformViewCreated: (id) => {
        _onPlatformViewCreated(id),
      },
    );
  }

  Widget iosView() {
    return UiKitView(
      viewType: 'igzafer/IgPlayerNative',
      creationParams: {
        "videoUrl": widget.videoUrl,
      },
      creationParamsCodec: const JSONMessageCodec(),
      onPlatformViewCreated: (id) => {
        _onPlatformViewCreated(id),
      },
    );
  }

  _onPlatformViewCreated(viewId) {
    _methodChannel = const MethodChannel("igzafer/NativeVideoPlayerMethodChannel");
  }
}
