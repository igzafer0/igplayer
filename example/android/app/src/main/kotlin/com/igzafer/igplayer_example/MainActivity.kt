package com.igzafer.igplayer_example

import com.igzafer.igplayer.video.VideoPlayerViewFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
       VideoPlayerViewFactory.registerWith(
            flutterEngine.platformViewsController.registry,
            flutterEngine.dartExecutor.binaryMessenger,
            this)

    }
}
