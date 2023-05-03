package com.igzafer.igplayer.video

import android.app.Activity
import android.content.Context
import android.util.Log
import android.view.View
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.platform.PlatformView

class VideoPlayerView internal constructor(
    context: Context?,
    activity: Activity?,
    messenger: BinaryMessenger?,
    args: Any?
) :
    PlatformView, MethodCallHandler {
    private val player: VideoPlayerLayout

    init {
        MethodChannel(messenger!!, "igzafer/NativeVideoPlayerMethodChannel").setMethodCallHandler(this)
        player = VideoPlayerLayout(context!!, activity, messenger, args)
        Log.d("winter","e girdi")

    }

    override fun getView(): View? {
        return player
    }

    fun setActivity(activity: Activity?) {
        player.setActivity(activity)
    }

    override fun dispose() {
        player.onDestroy()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.d("winter", call.method)
    }
}