package com.igzafer.igplayer.video

import android.app.Activity
import android.content.Context
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.google.android.exoplayer2.ExoPlayer
import com.google.android.exoplayer2.MediaItem
import com.google.android.exoplayer2.Player
import com.google.android.exoplayer2.analytics.AnalyticsListener
import com.google.android.exoplayer2.source.MediaSource
import com.google.android.exoplayer2.source.ProgressiveMediaSource
import com.google.android.exoplayer2.source.hls.HlsMediaSource
import com.google.android.exoplayer2.ui.StyledPlayerView
import com.google.android.exoplayer2.upstream.DataSource
import com.google.android.exoplayer2.upstream.DefaultDataSource
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory
import com.igzafer.igplayer.IPlayer
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.JSONMethodCodec
import org.json.JSONObject
import kotlin.math.abs


class VideoPlayerLayout : StyledPlayerView, IPlayer, EventChannel.StreamHandler {
    companion object {
        var exoPlayer: ExoPlayer? = null
         var url: String = ""
         var title: String = ""
         var subtitle: String = ""
         var artworkUrl: String = ""
         var autoPlay: Boolean= false
         var initialPosition:Int = 0
        fun skipPosition(newPosition: Int) {
            exoPlayer!!.seekTo(exoPlayer!!.currentPosition + (newPosition.toLong() * 1000))
        }
    }
    var innerPlayer:ExoPlayer?=null
    fun newPosition(newPosition: Int) {
        innerPlayer!!.seekTo(newPosition.toLong() * 1000)
    }

    private var eventSink: EventSink? = null
    private var activity: Activity? = null
    private var context: Context? = null
    private var messenger: BinaryMessenger? = null
    private var viewId: Int? = null

    private var videoNotificationManager: VideoNotificationManager? = null

    constructor(context: Context?) : super(context!!)
    constructor(
        context: Context, activity: Activity?,id:Int, messenger: BinaryMessenger?, arguments: Any?
    ) : super(context) {
        this.activity = activity
        this.context = context
        this.messenger = messenger
        this.viewId=id;

        val args = arguments as JSONObject
        url = args.getString("url")
        title = args.getString("title")
        subtitle = args.getString("subtitle")
        artworkUrl = args.getString("artworkUrl")
        autoPlay = args.getBoolean("autoPlay")
        initialPosition = args.getInt("initialPosition")

        initPlayer()
        initChannel()
        videoNotificationManager =
            VideoNotificationManager(context,  this, activity!!)
        videoNotificationManager!!.init()
        if (exoPlayer != null) {

            exoPlayer?.release();
        }

        exoPlayer = innerPlayer
    }

    private fun initChannel() {



    }

    override fun onListen(o: Any, eventSink: EventSink) {
        this.eventSink = eventSink
    }

    override fun onCancel(o: Any) {
        eventSink = null
    }

    fun playVideo() {
        innerPlayer!!.play()

    }
    fun pauseVideo() {
        innerPlayer!!.pause()

    }



    private fun initPlayer() {
        innerPlayer = ExoPlayer.Builder(context!!).setUseLazyPreparation(true).build()

        player = innerPlayer
        val dataSourceFactory: DataSource.Factory = DefaultDataSource.Factory(context!!)

        val videoSource: MediaSource
        if(url.contains(".m3u8") || url.contains(".m3u")) {
            videoSource =  HlsMediaSource.Factory(dataSourceFactory).createMediaSource(MediaItem.fromUri(url))
        }else{
            videoSource = ProgressiveMediaSource.Factory(dataSourceFactory).createMediaSource(
                MediaItem.fromUri(url)
            )
        }

        innerPlayer!!.setMediaSource(videoSource)
        innerPlayer!!.prepare()

        innerPlayer!!.playWhenReady = autoPlay

        innerPlayer!!.seekTo((initialPosition*1000).toLong());
        useController = false
        innerPlayer!!.addAnalyticsListener(object : AnalyticsListener {
            override fun onIsPlayingChanged(eventTime: AnalyticsListener.EventTime, isPlaying: Boolean) {
                val playerState = JSONObject()
                playerState.put("name", "isPlaying")
                playerState.put("state", isPlaying)
                eventSink?.success(playerState)
                videoNotificationManager!!.updateNotification()
                super.onIsPlayingChanged(eventTime, isPlaying)
            }

            override fun onPlaybackStateChanged(
                eventTime: AnalyticsListener.EventTime, state: Int
            ) {
                if (state == Player.STATE_ENDED) {
                    videoNotificationManager!!.updateNotification()
                }

                super.onPlaybackStateChanged(eventTime, state)
            }

        })

        getPlayerPosition()
    }

    private fun getPlayerPosition() {
        var oldTime = -1

        val handler = Handler(Looper.getMainLooper())
        val runnable: Runnable = object : Runnable {
            override fun run() {
                if ((innerPlayer!!.currentPosition / 1000).toInt() != oldTime) {
                    val message = JSONObject()
                    oldTime = (innerPlayer!!.currentPosition / 1000).toInt()
                    message.put("name", "playerTime")
                    message.put("time", (innerPlayer!!.currentPosition / 1000).toInt())
                    eventSink?.success(message)

                    val durationMessage = JSONObject()
                    durationMessage.put("name", "playerDuration")
                    durationMessage.put("duration", (innerPlayer!!.duration / 1000).toInt())
                    eventSink?.success(durationMessage)

                }
                handler.postDelayed(this, 250)
            }

        }
        handler.post(runnable)

    }

    fun onMediaChanged(arguments: Any) {
        val args = arguments as HashMap<*, *>
        url = args["url"]!! as String
        title =args["title"]!! as String
        subtitle =args["subtitle"]!! as String
        artworkUrl =args["artworkUrl"]!! as String
        autoPlay = args["autoPlay"]!! as Boolean

        val dataSourceFactory: DataSource.Factory = DefaultDataSource.Factory(context!!)

        val videoSource: MediaSource
        if(url.contains(".m3u8") || url.contains(".m3u")) {
            videoSource =  HlsMediaSource.Factory(dataSourceFactory).createMediaSource(MediaItem.fromUri(url))
        } else {
        videoSource = ProgressiveMediaSource.Factory(dataSourceFactory).createMediaSource(
            MediaItem.fromUri(url)
        ) }
        innerPlayer!!.setMediaSource(videoSource)
        innerPlayer!!.prepare()

        if (autoPlay){
            innerPlayer!!.play()
            val playerState = JSONObject()
            playerState.put("name", "isPlaying")
            playerState.put("state", true)
            eventSink?.success(playerState)
        }
        videoNotificationManager!!.setupMediaSession()

    }
    fun changeSpeed(speed:Double){
        innerPlayer!!.setPlaybackSpeed(abs(speed.toFloat()))
    }
    override fun onDestroy() {
        try {
            innerPlayer!!.stop()
            val playerState = JSONObject()
            playerState.put("name", "isPlaying")
            playerState.put("state", false)
            eventSink?.success(playerState)
            innerPlayer!!.release()
            videoNotificationManager!!.doUnbindMediaNotificationManagerService()
            videoNotificationManager!!.cleanPlayerNotification()
            exoPlayer = null
        } catch (e: Exception) {
        }


    }


    fun setActivity(activity: Activity?) {
        this.activity = activity
    }

}