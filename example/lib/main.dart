import 'package:flutter/material.dart';
import 'package:igplayer/manage/igplayer_controller.dart';
import 'package:igplayer/view/ig_video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final igPlayerController = IgPlayerController();
  var videoUrl =
      "https://video-previews.elements.envatousercontent.com/files/c499c34a-2618-4900-be84-b04f9e8cf443/video_preview_h264.mp4";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: IgVideoPlayer(
          videoUrl: videoUrl,
          igPlayerController: igPlayerController,
          initialValues: (p0) {},
          autoPlay: true,
        ),
      ),
    );
  }
}
