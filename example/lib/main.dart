import 'dart:math';

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
    WidgetsFlutterBinding.ensureInitialized();

    super.initState();
  }

  final igPlayerController = IgPlayerController();
  int index = 0;
  var list = [
    "https://player.vimeo.com/progressive_redirect/playback/788609312/rendition/720p/file.mp4?loc=external&oauth2_token_id=1669343316&signature=11c76e88b0868c8bf5119c752406dc0ee9d278eda5cf21db204bc588697f3cd4",
    "https://player.vimeo.com/external/830090120.m3u8?s=68861329fcf56f2eae4dad8b031b9d5b7bf14fdb&oauth2_token_id=1669343673",
  ];
  bool isPlaying = false;
  String title = "oynamış";
  double volume = 1;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: FloatingActionButton(onPressed: () {
          setState(() {
            index += 1;
            title = "aynur";
          });
        }),
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            StreamBuilder(
                stream: igPlayerController.isPlaying.stream,
                builder: (context, d) {
                  if (d.data != null) {
                    isPlaying = d.data!;
                    return Text("isPlaying: ${d.data}");
                  }
                  return Container();
                }),
            StreamBuilder(
                stream: igPlayerController.playerTimeListener.stream,
                builder: (context, stream) {
                  if (stream.data != null) {
                    return Slider(
                        value: stream.data!.toDouble(),
                        max: igPlayerController.playerDuration.toDouble(),
                        onChangeStart: (value) => igPlayerController.pause(),
                        onChangeEnd: (value) => igPlayerController.play(),
                        onChanged: (value) => igPlayerController.newPosition(value.toInt()));
                  }
                  return Container();
                }),
            GestureDetector(
                onTap: () {
                  igPlayerController.enablePip(false);
                  isPlaying == true ? igPlayerController.pause() : igPlayerController.play();
                },
                child: Container(width: 100, height: 100, color: Colors.blue)),
            GestureDetector(
                onTap: () {
                  igPlayerController.enablePip(true);

                  igPlayerController.newPosition(1);
                },
                child: Container(width: 100, height: 100, color: Colors.red)),
            GestureDetector(
                onTap: () {
                  setState(() {
                    volume = volume == 0 ? 1 : 0;
                    igPlayerController.changeVolume(volume);
                    debugPrint("volume $volume");
                  });
                },
                child: Container(width: 100, height: 100, color: Colors.green)),
            SizedBox(
              height: 250,
              child: IgVideoPlayer(
                videoUrl: list[index],
                title: title,
                initialValues: (controller) {},
                subTitle: "TEST2",
                autoPlay: false,
                volume: volume,
                initialPosition: 35,
                igPlayerController: igPlayerController,
                artworkUrl:
                    "https://i.discogs.com/_EqNbST80njT5rTLt3Ewq2uga8y0ciG9Ax02m2ea90k/rs:fit/g:sm/q:90/h:600/w:600/czM6Ly9kaXNjb2dz/LWRhdGFiYXNlLWlt/YWdlcy9BLTExMjY4/NjktMTU4OTc1MjQ0/My04ODI1LmpwZWc.jpeg",
              ),
            ),
          ],
        ),
      ),
    );
  }

  void listener() {}
}
