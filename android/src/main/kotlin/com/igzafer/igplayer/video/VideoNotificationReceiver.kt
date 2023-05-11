package com.igzafer.igplayer.video

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.view.KeyEvent
import com.google.android.exoplayer2.Player
import com.google.android.exoplayer2.Player.RepeatMode

class VideoNotificationReceiver : BroadcastReceiver() {
    override fun onReceive(p0: Context?, p1: Intent?) {


        if (Intent.ACTION_MEDIA_BUTTON == p1?.action) {
            val event: KeyEvent = p1.getParcelableExtra(Intent.EXTRA_KEY_EVENT)!!
            if (event.action == KeyEvent.ACTION_DOWN) {
                when (event.keyCode) {
                    KeyEvent.KEYCODE_MEDIA_PAUSE -> VideoPlayerLayout.exoPlayer?.pause()
                    KeyEvent.KEYCODE_MEDIA_PLAY -> VideoPlayerLayout.exoPlayer?.play()
                    KeyEvent.KEYCODE_FORWARD -> VideoPlayerLayout.skipPosition(10)
                    KeyEvent.KEYCODE_MEDIA_REWIND ->  VideoPlayerLayout.skipPosition(-10)
                }
            }
        }

    }
}