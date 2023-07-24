package com.igzafer.igplayer

import android.app.Activity
import android.util.Log
import androidx.annotation.NonNull
import com.igzafer.igplayer.video.VideoPlayerViewFactory

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.lang.Exception


class IgplayerPlugin : FlutterPlugin, ActivityAware {

    private lateinit var activity: Activity
    private lateinit var playerViewFactory: VideoPlayerViewFactory


    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        playerViewFactory = VideoPlayerViewFactory.registerWith(
            binding.platformViewRegistry, binding.binaryMessenger, activity
        )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        playerViewFactory.onDetachActivity()
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        playerViewFactory.onAttachActivity(binding.activity)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        playerViewFactory.onDetachActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        playerViewFactory.onAttachActivity(binding.activity)
    }

    override fun onDetachedFromActivity() {
        playerViewFactory.onDetachActivity()
    }

}
