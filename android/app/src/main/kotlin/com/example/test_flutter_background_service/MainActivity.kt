package com.example.envoi_sms_fg_v4

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle  // Importation nécessaire de Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    // Le canal de notification utilisé par le service en arrière-plan
    private val CHANNEL = "my_foreground_channel"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Créer le canal de notification pour Android 8.0 et plus
        createNotificationChannel()

        // Vous pouvez initialiser d'autres configurations ici
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL,
                "Foreground Service Channel",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    // Autres méthodes nécessaires pour l'exécution du service...
}
