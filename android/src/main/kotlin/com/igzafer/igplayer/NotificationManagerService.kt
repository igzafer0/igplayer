package com.igzafer.igplayer

import android.app.Service
import android.content.Intent
import android.os.Binder
import android.os.IBinder

class NotificationManagerService : Service() {

    private val mBinder: Binder = MediaNotificationManagerServiceBinder()
    private var iPlayer: IPlayer? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return super.onStartCommand(intent, flags, startId)
    }

    override fun onBind(intent: Intent?): IBinder {
        return mBinder
    }

    override fun onDestroy() {
        iPlayer?.onDestroy()
    }

    override fun onUnbind(intent: Intent?): Boolean {
        iPlayer?.onDestroy()
        stopSelf()
        return false
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        super.onTaskRemoved(rootIntent)
        iPlayer?.onDestroy()
        stopSelf()
    }


    fun setActivePlayer(player: IPlayer?) {
        if (iPlayer != null) {
            iPlayer?.onDestroy()
        }
        iPlayer = player
    }


    inner class MediaNotificationManagerServiceBinder : Binder() {
        fun getService(): NotificationManagerService {
            return this@NotificationManagerService
        }
    }
}