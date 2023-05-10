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
    "https://video-previews.elements.envatousercontent.com/files/c7f6523b-b334-481c-8f9a-dbaa6ceb17ea/video_preview_h264.mp4",
    "https://player.vimeo.com/progressive_redirect/playback/788609312/rendition/720p/file.mp4?loc=external&oauth2_token_id=1669343316&signature=11c76e88b0868c8bf5119c752406dc0ee9d278eda5cf21db204bc588697f3cd4",
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
                  igPlayerController.skip(-50);
                },
                child: Container(width: 100, height: 100, color: Colors.green)),
            SizedBox(
              height: 250,
              child: IgVideoPlayer(
                videoUrl: list[index],
                igPlayerController: igPlayerController,
                artworkUrl:
                    "https://instagram.fayt1-1.fna.fbcdn.net/v/t51.2885-19/332834397_933324027667962_5038322828268599181_n.jpg?stp=dst-jpg_s320x320&_nc_ht=instagram.fayt1-1.fna.fbcdn.net&_nc_cat=106&_nc_ohc=jXCxi1VSX3YAX_ZvCou&edm=AOQ1c0wBAAAA&ccb=7-5&oh=00_AfBRSOqNLvbGUddizDXov2_NniPRoU7abCTQX-hbhWT_yA&oe=6460EFA9&_nc_sid=8fd12b",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
