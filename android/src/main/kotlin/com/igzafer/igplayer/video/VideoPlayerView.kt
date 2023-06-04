package com.igzafer.igplayer.video

import android.app.Activity
import android.content.Context
import android.util.Log
import android.view.View
import com.igzafer.igplayer.video.VideoPlayerLayout.Companion.skipPosition
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.JSONMethodCodec
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.platform.PlatformView

class VideoPlayerView internal constructor(
    context: Context?, activity: Activity?,id:Int, messenger: BinaryMessenger?, args: Any?
) : PlatformView, MethodCallHandler {
    private val player: VideoPlayerLayout

    init {


        MethodChannel(messenger!!, "igzafer/NativeVideoPlayerMethodChannel$id").setMethodCallHandler(
            this
        )
        player = VideoPlayerLayout(context!!, activity,id, messenger, args)
        EventChannel(
            messenger, "igzafer/NativeVideoPlayerEventChannel$id", JSONMethodCodec.INSTANCE
        ).setStreamHandler(player)
    }

    override fun getView(): View {
        return player
    }

    fun setActivity(activity: Activity?) {
        player.setActivity(activity)
    }

    override fun dispose() {
        player.onDestroy()
    }



    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "play" -> {
                player.playVideo()
            }
            "pause" -> {
                player.pauseVideo()
            }
            "newPosition" -> {
                player.newPosition(call.arguments as Int)
            }
            "skipPosition" -> {

                skipPosition(call.arguments as Int)
            }
            "mediaChanged" -> {
                player.onMediaChanged(call.arguments)
            }
            "changeSpeed" -> {
                player.changeSpeed(call.arguments as Double)
            }
            "dispose" -> {
                dispose()
                result.success(true)
            }
        }
    }
}