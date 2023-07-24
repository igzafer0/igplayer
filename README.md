# Türkçe

Ön uyarı: Kütüphane test aşamasındadır, deneysel projelerinizde kullanılabilir ancak profesyonel bir ortam için uygun değildir. Detek almaktan asla çekinmeyin. 

Linkedin adresim: https://www.linkedin.com/in/zafercetin0/

IgPlayer; android ve ios üzerinde, arka planda ve pip modunda çalışabilen bir video oynatıcıdır. Sadece bir video oynatıcı. Yani tüm o oynatıcı tasarımını sizin yapmanız gerekiyor :).

IgPlayer android tarafta `ExoPlayer`, ios tarafta `AVPlayer` çalıştırır ve bu sayede popüler native oynatıcıların tüm özgürlüklerine erişebilir.

## Örnek

``` dart
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
```

# English

Disclaimer: This library is in the testing phase and can be used for experimental projects, and it is not suitable for professional environments. Don't hesitate to provide feedback.

My Linkedin address: https://www.linkedin.com/in/zafercetin0/

IgPlayer is a video player that works on both android and ios platforms with support for background playback and Picture-in-Picture mode. It is intended to be a video player only. So it does not include a video player design.

IgPlayer utilizes `ExoPlayer` on the android side and `AVPlayer` on the ios side, granting access to all the capabilities of popular native players.

## Example

``` dart
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
```
