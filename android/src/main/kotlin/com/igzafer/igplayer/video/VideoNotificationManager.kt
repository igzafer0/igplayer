package com.igzafer.igplayer.video

import android.app.Activity
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.media.MediaMetadata
import android.os.Build
import android.os.IBinder
import android.support.v4.media.MediaMetadataCompat
import android.support.v4.media.session.MediaSessionCompat
import android.support.v4.media.session.PlaybackStateCompat
import android.util.Log
import android.view.KeyEvent
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import com.igzafer.igplayer.NotificationManagerService
import com.igzafer.igplayer.NotificationUtil
import com.igzafer.igplayer.R
import java.lang.Exception

class VideoNotificationManager(
    val context: Context, val instance: VideoPlayerLayout, val activity: Activity
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
            init {
                Log.d("winter","girdi aslında")
            }
            override fun onServiceConnected(componentName: ComponentName, service: IBinder) {
                mMediaNotificationManagerService = (service as NotificationManagerService.MediaNotificationManagerServiceBinder).getService()
                mMediaNotificationManagerService!!.setActivePlayer(instance)
                Log.d("winter","connected aslında")

            }

            override fun onServiceDisconnected(componentName: ComponentName) {
                mMediaNotificationManagerService = null
                Log.d("winter","disconnected aslında")

            }
        }

    private var mMediaSessionCompat: MediaSessionCompat? = null
    private fun setupMediaSession() {
        val receiver = ComponentName(
            context.packageName, VideoNotificationReceiver::class.java.name
        )

        mMediaSessionCompat = MediaSessionCompat(
            context, VideoPlayerLayout::class.java.simpleName, receiver, null
        )
        mMediaSessionCompat!!.setMetadata(MediaMetadataCompat.Builder().putString("fsfsf","").build())

        mMediaSessionCompat!!.setCallback(MediaSessionCallback())
        mMediaSessionCompat!!.isActive = true
         updateNotification(1)


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

     fun updateNotification( capabilities:Long) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            createNotificationChannel()
        }
        val notificationBuilder: NotificationCompat.Builder = NotificationUtil().from(
            activity, context, mMediaSessionCompat!!, mNotificationChannelId
        )
         if (capabilities and PlaybackStateCompat.ACTION_PAUSE != 0L) {
             notificationBuilder.addAction(
                 R.drawable.ic_pause, "Pause",
                 NotificationUtil.getActionIntent(context, KeyEvent.KEYCODE_MEDIA_PAUSE)
             )
         }

         if (capabilities and PlaybackStateCompat.ACTION_PLAY != 0L) {
             notificationBuilder.addAction(
                 R.drawable.ic_pause, "Play",
                 NotificationUtil.getActionIntent(context, KeyEvent.KEYCODE_MEDIA_PLAY)
             )
         }


         val notificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
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
        Log.d("winter","çalışu manager")
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