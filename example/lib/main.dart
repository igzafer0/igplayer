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
  int index = 0;
  var list = [
    "https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/1080/Big_Buck_Bunny_1080_10s_1MB.mp4",
    "https://video-previews.elements.envatousercontent.com/files/c7f6523b-b334-481c-8f9a-dbaa6ceb17ea/video_preview_h264.mp4"
  ];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: FloatingActionButton(onPressed: () {
          setState(() {
            index += 1;
          });
        }),
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            StreamBuilder(
                stream: igPlayerController.playerTimeListener.stream,
                builder: (context, stream) {
                  return Slider(
                      value: stream.data!.toDouble(),
                      max: igPlayerController.playerDuration.toDouble(),
                      onChanged: (value) => igPlayerController.newPosition(value.toInt()));
                }),
            GestureDetector(
                onTap: () {
                  igPlayerController.play();
                },
                child: Container(width: 100, height: 100, color: Colors.blue)),
            GestureDetector(
                onTap: () {
                  igPlayerController.newPosition(1);
                },
                child: Container(width: 100, height: 100, color: Colors.red)),
            GestureDetector(
                onTap: () {
                  igPlayerController.skip(-5);
                },
                child: Container(width: 100, height: 100, color: Colors.green)),
            SizedBox(
              height: 250,
              child: IgVideoPlayer(
                videoUrl: list[index],
                igPlayerController: igPlayerController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
