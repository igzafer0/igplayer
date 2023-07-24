package com.igzafer.igplayer

import android.app.Activity
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.support.v4.media.MediaMetadataCompat
import android.support.v4.media.session.MediaSessionCompat
import android.view.KeyEvent
import androidx.core.app.NotificationCompat


class NotificationUtil {

    fun from(
        activity: Activity,
        context: Context,
        mediaSession: MediaSessionCompat,
        notificationChannelId: String?
    ): NotificationCompat.Builder {
        val controller = mediaSession.controller

        val mediaMetadata = controller.metadata

        val description = mediaMetadata.description
        val builder = NotificationCompat.Builder(
            context, notificationChannelId!!
        )

        builder.setContentTitle(description.title)
            .setContentText(description.subtitle)
            .setStyle(
                androidx.media.app.NotificationCompat.MediaStyle()
                    .setMediaSession(mediaSession.sessionToken)
                    
            )
            .setLargeIcon(mediaMetadata.getBitmap(MediaMetadataCompat.METADATA_KEY_ART))
            .setColorized(true)
            .setAutoCancel(true)
            .setOngoing(true)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setSmallIcon(R.drawable.ic_pause)
            .setDeleteIntent(
                getActionIntent(
                    context,
                    KeyEvent.KEYCODE_MEDIA_STOP
                )
            )

        val intent = Intent(context, activity.javaClass)
        intent.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
        val pendingIntent =
            PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_MUTABLE)

        builder.setContentIntent(pendingIntent)
        return builder
    }

    companion object {
        fun getActionIntent(context: Context, mediaKeyEvent: Int): PendingIntent? {
            val intent = Intent(Intent.ACTION_MEDIA_BUTTON)
            intent.setPackage(context.packageName)

            intent.putExtra(Intent.EXTRA_KEY_EVENT, KeyEvent(KeyEvent.ACTION_DOWN, mediaKeyEvent))
            return PendingIntent.getBroadcast(
                context, mediaKeyEvent, intent, PendingIntent.FLAG_MUTABLE
            )
        }
    }

}