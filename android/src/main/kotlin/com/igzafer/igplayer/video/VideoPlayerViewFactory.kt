package com.igzafer.igplayer.video

import android.app.Activity
import android.content.Context
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.JSONMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.platform.PlatformViewRegistry
import java.lang.Exception

class VideoPlayerViewFactory(
    private val binaryMessenger: BinaryMessenger, private var activity: Activity
) : PlatformViewFactory(JSONMessageCodec.INSTANCE) {

    private var videoPlayerView: VideoPlayerView? = null


    override fun create(context: Context, id: Int, args: Any?): PlatformView {
        videoPlayerView = VideoPlayerView(context, activity,id, binaryMessenger, args)
        return videoPlayerView!!
    }

    private fun onDestroy() {
        if (videoPlayerView != null) {
            videoPlayerView!!.dispose()
        }
    }

    fun onAttachActivity(activity: Activity) {
        this.activity = activity
        videoPlayerView!!.setActivity(activity)
    }

    fun onDetachActivity() {
        onDestroy()
    }

    companion object {
        fun registerWith(
            viewRegistry: PlatformViewRegistry, messenger: BinaryMessenger, activity: Activity
        ): VideoPlayerViewFactory {
            val plugin = VideoPlayerViewFactory(messenger, activity)
            viewRegistry.registerViewFactory("igzafer/IgVideoPlayerNative", plugin)
            return plugin
        }
    }
}