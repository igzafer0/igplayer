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
  @override
  void initState() {
    super.initState();
  }

  final igPlayerController = IgPlayerController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            StreamBuilder(
                stream: igPlayerController.playerTimeListener.stream,
                builder: (context, stream) {
                  return Text(stream.data.toString());
                }),
            GestureDetector(
                onTap: () {
                  igPlayerController.newPosition(1000);
                },
                child: Container(width: 100, height: 100, color: Colors.red)),
            SizedBox(
              height: 250,
              child: IgVideoPlayer(
                videoUrl:
                    "https://www.shutterstock.com/shutterstock/videos/1068074216/preview/stock-footage-surgeons-use-augmented-reality-vr-glasses-to-investigate-patient-lungs-status-virus-detection-d.webm",
                igPlayerController: igPlayerController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
