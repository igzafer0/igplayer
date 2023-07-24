package com.igzafer.igplayer.video

import android.R.attr.subtitle
import android.app.Activity
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.graphics.Bitmap
import android.graphics.drawable.Drawable
import android.os.Build
import android.os.IBinder
import android.support.v4.media.MediaMetadataCompat
import android.support.v4.media.session.MediaSessionCompat
import android.support.v4.media.session.PlaybackStateCompat
import android.util.Log
import android.view.KeyEvent
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import com.bumptech.glide.Glide
import com.bumptech.glide.request.target.CustomTarget
import com.igzafer.igplayer.NotificationManagerService
import com.igzafer.igplayer.NotificationUtil
import com.igzafer.igplayer.R


class VideoNotificationManager(
    val context: Context,  val instance: VideoPlayerLayout, val activity: Activity
) {

    private val NOTIFICATION_ID = 0
    var mNotificationChannelId = "NotificationBarController"

    fun init() {
        setupMediaSession()
        doBindMediaNotificationManagerService()
    }


    private var mMediaNotificationManagerService: NotificationManagerService? = null
    private val mMediaNotificationManagerServiceConnection: ServiceConnection =
        object : ServiceConnection {
           
            override fun onServiceConnected(componentName: ComponentName, service: IBinder) {
                mMediaNotificationManagerService = (service as NotificationManagerService.MediaNotificationManagerServiceBinder).getService()
                mMediaNotificationManagerService!!.setActivePlayer(instance)

            }

            override fun onServiceDisconnected(componentName: ComponentName) {
                mMediaNotificationManagerService = null

            }
        }

    private var mMediaSessionCompat: MediaSessionCompat? = null
     fun setupMediaSession() {
        val receiver = ComponentName(
            context.packageName, VideoNotificationReceiver::class.java.name
        )

        mMediaSessionCompat = MediaSessionCompat(
            context, VideoPlayerLayout::class.java.simpleName, receiver, null
        )
        mMediaSessionCompat!!.setMetadata(MediaMetadataCompat.Builder().putString("fsfsf","").build())

        mMediaSessionCompat!!.setCallback(MediaSessionCallback())
        mMediaSessionCompat!!.isActive = true
        setAudioMetadataWithArtwork()
        updateNotification()


    }
    private fun setAudioMetadataWithArtwork() {
        if (VideoPlayerLayout.artworkUrl.isNotEmpty()) {
            Glide.with(context).asBitmap().load(VideoPlayerLayout.artworkUrl).into(object : CustomTarget<Bitmap?>() {
                override fun onResourceReady(
                    resource: Bitmap,
                    transition: com.bumptech.glide.request.transition.Transition<in Bitmap?>?
                ) {
                    setAudioMetadata(resource)
                }

                override fun onLoadFailed(errorDrawable: Drawable?) {
                    setAudioMetadata(null)

                    super.onLoadFailed(errorDrawable)
                }

                override fun onLoadCleared(placeholder: Drawable?) {}

            })
        } else {
            setAudioMetadata(null)
        }
    }
    private fun setAudioMetadata(artwork: Bitmap?) {
        val metadataBuilder = MediaMetadataCompat.Builder()
            .putString(MediaMetadataCompat.METADATA_KEY_DISPLAY_TITLE, VideoPlayerLayout.title)
            .putString(MediaMetadataCompat.METADATA_KEY_TITLE, "igplayer")
            .putString(MediaMetadataCompat.METADATA_KEY_DISPLAY_SUBTITLE, VideoPlayerLayout.subtitle)

        if (artwork != null) {
            metadataBuilder.putBitmap(MediaMetadataCompat.METADATA_KEY_ART, artwork)
        }

        val metadata = metadataBuilder.build()

        mMediaSessionCompat!!.setMetadata(metadata)
    }
    private class MediaSessionCallback : MediaSessionCompat.Callback() {
        override fun onPause() {
            VideoPlayerLayout.exoPlayer!!.pause()
        }

        override fun onPlay() {
            VideoPlayerLayout.exoPlayer!!.play()

        }

        override fun onSeekTo(pos: Long) {
            VideoPlayerLayout.exoPlayer!!.seekTo(pos)
        }

        override fun onStop() {
            VideoPlayerLayout.exoPlayer!!.stop()

        }
    }

     fun updateNotification() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            createNotificationChannel()
        }
        val notificationBuilder: NotificationCompat.Builder = NotificationUtil().from(
            activity, context, mMediaSessionCompat!!, mNotificationChannelId
        )
         notificationBuilder.addAction(R.drawable.ic_replay_10, "replay",
             NotificationUtil.getActionIntent(context, KeyEvent.KEYCODE_MEDIA_REWIND));

         if(VideoPlayerLayout.exoPlayer?.isPlaying==true){
             notificationBuilder.addAction(R.drawable.ic_pause, "pause",
                 NotificationUtil.getActionIntent(context, KeyEvent.KEYCODE_MEDIA_PAUSE));

         }else{
             notificationBuilder.addAction(R.drawable.ic_play, "play",
                 NotificationUtil.getActionIntent(context, KeyEvent.KEYCODE_MEDIA_PLAY));

         }
         notificationBuilder.addAction(R.drawable.is_forward_10, "forward",
             NotificationUtil.getActionIntent(context, KeyEvent.KEYCODE_FORWARD));


         val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
         val notification=notificationBuilder.build()
         notification.flags = Notification.FLAG_NO_CLEAR;

         notificationManager.notify(NOTIFICATION_ID, notification)
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun createNotificationChannel() {
        val notificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channelNameDisplayedToUser: CharSequence = "Notification Bar Controls"
        val importance = NotificationManager.IMPORTANCE_LOW
        val newChannel = NotificationChannel(
            mNotificationChannelId, channelNameDisplayedToUser, importance
        )
        newChannel.description = "All notifications"
        newChannel.setShowBadge(false)
        newChannel.lockscreenVisibility = Notification.VISIBILITY_PUBLIC
        newChannel.enableLights(true)
        notificationManager.createNotificationChannel(newChannel)
    }


    private var mIsBoundMediaNotificationManagerService = false
    private fun doBindMediaNotificationManagerService() {
        try {
            val service = Intent(context, NotificationManagerService::class.java)

            context.bindService(
                service, mMediaNotificationManagerServiceConnection, Context.BIND_AUTO_CREATE
            )
            mIsBoundMediaNotificationManagerService = true
            context.startService(service)
        }catch (e:Exception){}

    }

    fun doUnbindMediaNotificationManagerService() {
        if (mIsBoundMediaNotificationManagerService) {
            try {
                context.unbindService(mMediaNotificationManagerServiceConnection)
                mIsBoundMediaNotificationManagerService = false
            }catch (e:Exception){}

        }
    }

    fun cleanPlayerNotification() {
        try {
            val notificationManager =
                context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.cancel(NOTIFICATION_ID)
        }catch (e:Exception){}

    }


}