package com.igzafer.igplayer.video

import android.app.Activity
import android.content.Context
import android.net.Uri
import android.util.Log
import com.google.android.exoplayer2.ExoPlayer
import com.google.android.exoplayer2.MediaItem
import com.google.android.exoplayer2.source.MediaSource
import com.google.android.exoplayer2.source.ProgressiveMediaSource
import com.google.android.exoplayer2.source.hls.HlsMediaSource
import com.google.android.exoplayer2.trackselection.DefaultTrackSelector
import com.google.android.exoplayer2.ui.StyledPlayerView
import com.google.android.exoplayer2.upstream.DataSource
import com.google.android.exoplayer2.upstream.DefaultDataSource
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory
import com.google.android.exoplayer2.util.Util
import com.igzafer.igplayer.IPlayer
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.JSONMethodCodec
import org.json.JSONObject

class VideoPlayerLayout : StyledPlayerView, IPlayer, EventChannel.StreamHandler {

    var mPlayerView: ExoPlayer? = null
    var isBound = true

    private var eventSink: EventSink? = null

    private var activity: Activity? = null


    private var context: Context? = null
    private var messenger: BinaryMessenger? = null
    private var url: String? = ""

    constructor(context: Context?) : super(context!!) {}
    constructor(
        context: Context, activity: Activity?, messenger: BinaryMessenger?, arguments: Any?
    ) : super(context) {
        this.activity = activity
        this.context = context
        this.messenger = messenger
        try {
            val args = arguments as JSONObject
            url = args.getString("url")
            Log.d("winter", "url $url")
            initPlayer()
        } catch (e: Exception) {
        }


    }

    override fun onListen(o: Any, eventSink: EventSink) {
        this.eventSink = eventSink
    }

    override fun onCancel(o: Any) {
        eventSink = null
    }

    private fun initPlayer() {

        mPlayerView = ExoPlayer.Builder(context!!).setUseLazyPreparation(true).build()
        mPlayerView!!.playWhenReady = true

        player = mPlayerView

        EventChannel(
            messenger,
            "igzafer/NativeVideoPlayerEventChannel",
            JSONMethodCodec.INSTANCE
        ).setStreamHandler(this)


        val dataSourceFactory: DataSource.Factory = DefaultDataSource.Factory(context!!)


        val videoSource: MediaSource
        videoSource = ProgressiveMediaSource.Factory(dataSourceFactory).createMediaSource(
            MediaItem.fromUri(url!!)
        )


        mPlayerView!!.setMediaSource(videoSource)
    }



    override fun onDestroy() {

        isBound = false
        mPlayerView!!.stop(true)
        mPlayerView!!.release()


    }


    fun setActivity(activity: Activity?) {
        this.activity = activity
    }

}