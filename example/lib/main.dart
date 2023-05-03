import 'package:flutter/material.dart';

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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: const IgVideoPlayer(
              videoUrl:
                  "https://www.shutterstock.com/shutterstock/videos/1068074216/preview/stock-footage-surgeons-use-augmented-reality-vr-glasses-to-investigate-patient-lungs-status-virus-detection-d.webm")),
    );
  }
}
