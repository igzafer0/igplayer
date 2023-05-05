package com.igzafer.igplayer.video

import android.app.Activity
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.google.android.exoplayer2.ExoPlayer
import com.google.android.exoplayer2.MediaItem
import com.google.android.exoplayer2.Player
import com.google.android.exoplayer2.analytics.AnalyticsListener
import com.google.android.exoplayer2.source.MediaSource
import com.google.android.exoplayer2.source.ProgressiveMediaSource
import com.google.android.exoplayer2.ui.StyledPlayerView
import com.google.android.exoplayer2.upstream.DataSource
import com.google.android.exoplayer2.upstream.DefaultDataSource
import com.igzafer.igplayer.IPlayer
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.JSONMethodCodec
import org.json.JSONObject
import java.util.Timer


class VideoPlayerLayout : StyledPlayerView, IPlayer, EventChannel.StreamHandler {
    companion object {
        var exoPlayer: ExoPlayer? = null
    }

    private var eventSink: EventSink? = null
    private var activity: Activity? = null
    private var context: Context? = null
    private var messenger: BinaryMessenger? = null
    private var url: String? = ""
    private var videoNotificationManager: VideoNotificationManager? = null

    constructor(context: Context?) : super(context!!)
    constructor(
        context: Context, activity: Activity?, messenger: BinaryMessenger?, arguments: Any?
    ) : super(context) {
        this.activity = activity
        this.context = context
        this.messenger = messenger

        val args = arguments as JSONObject
        url = args.getString("url")

        initPlayer()
         initChannel()
        videoNotificationManager = VideoNotificationManager(context, this, activity!!)
        videoNotificationManager!!.init()

    }

    private fun initChannel() {
        EventChannel(
            messenger, "igzafer/NativeVideoPlayerEventChannel", JSONMethodCodec.INSTANCE
        ).setStreamHandler(this)

    }

    override fun onListen(o: Any, eventSink: EventSink) {
        this.eventSink = eventSink
    }

    override fun onCancel(o: Any) {
        eventSink = null
    }

    fun playVideo() {
        exoPlayer!!.prepare()
        exoPlayer!!.play()
    }
    fun newPosition(newPosition: Int){
        exoPlayer!!.seekTo(newPosition.toLong())
    }
    private fun initPlayer() {
        exoPlayer = ExoPlayer.Builder(context!!).setUseLazyPreparation(true).build()

        player = exoPlayer
        val dataSourceFactory: DataSource.Factory = DefaultDataSource.Factory(context!!)

        val videoSource: MediaSource
        videoSource = ProgressiveMediaSource.Factory(dataSourceFactory).createMediaSource(
            MediaItem.fromUri(url!!)
        )
        exoPlayer!!.setMediaSource(videoSource)
        exoPlayer!!.playWhenReady = true
        useController = false
        exoPlayer!!.addAnalyticsListener(object : AnalyticsListener {

            override fun onIsPlayingChanged(
                eventTime: AnalyticsListener.EventTime, isPlaying: Boolean
            ) {
                Log.d("winter", "test")
                videoNotificationManager!!.updateNotification(1)
                super.onIsPlayingChanged(eventTime, isPlaying)
            }

            override fun onPlaybackStateChanged(
                eventTime: AnalyticsListener.EventTime, state: Int
            ) {
                if (state == Player.STATE_ENDED) {
                    Log.d("winter", "girdi girdi")

                    videoNotificationManager!!.updateNotification(2)
                }

                super.onPlaybackStateChanged(eventTime, state)
            }

        })

        getPlayerPosition()
    }

    private fun getPlayerPosition() {
        var oldTime =-1

        val handler = Handler(Looper.getMainLooper())
        val runnable: Runnable = object : Runnable {
            override fun run() {
                if((exoPlayer!!.currentPosition/1000).toInt()!=oldTime){
                   val message = JSONObject()
                    oldTime=    (exoPlayer!!.currentPosition/1000).toInt()
                    message.put("name","playerTime")
                    message.put("time",(exoPlayer!!.currentPosition/1000).toInt())
                    eventSink?.success(message)
                }
                handler.postDelayed(this,250)
            }

        }
        handler.post(runnable)

    }

    override fun onDestroy() {
        try {
            exoPlayer!!.stop()
            exoPlayer!!.release()
            videoNotificationManager!!.doUnbindMediaNotificationManagerService()
            videoNotificationManager!!.cleanPlayerNotification()
        } catch (e: Exception) {
        }


    }


    fun setActivity(activity: Activity?) {
        this.activity = activity
    }

}