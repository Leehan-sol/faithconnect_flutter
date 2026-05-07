package com.hansol.faithconnect_flutter

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannel()
    }

    /**
     * Android 8+ (API 26+) 알림 채널 등록.
     * AndroidManifest.xml의 default_notification_channel_id 메타데이터와 동일한 ID 사용.
     * 채널이 등록되어 있어야 백그라운드 푸시가 시스템 트레이에 표시됨.
     */
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "default_channel",
                "FaithConnect 알림",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "기도 응답·답글 등 앱 알림"
                enableVibration(true)
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager?.createNotificationChannel(channel)
        }
    }
}
