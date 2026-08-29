package com.example.hisabio

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "file_opener"

    override fun onCreate(savedInstanceState: Bundle?) {
        installSplashScreen()
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            if (call.method == "openFile") {
                val uriString = call.argument<String>("uri")
                val mimeType = call.argument<String>("mimeType")

                if (uriString.isNullOrEmpty()) {
                    result.error("URI", "URI is null", null)
                    return@setMethodCallHandler
                }

                try {
                    val uri = Uri.parse(uriString)

                    val intent = Intent(Intent.ACTION_VIEW).apply {
                        setDataAndType(uri, mimeType)
                        addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    }

                    startActivity(Intent.createChooser(intent, "Open with"))
                    result.success(true)

                } catch (e: Exception) {
                    result.error("OPEN_ERROR", e.message, null)
                }

            } else {
                result.notImplemented()
            }
        }
    }
}




//package com.example.hisabio
//
//import android.os.Bundle
//import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
//import io.flutter.embedding.android.FlutterActivity
//
//class MainActivity : FlutterActivity() {
//
//    override fun onCreate(savedInstanceState: Bundle?) {
//        installSplashScreen()
//
//        super.onCreate(savedInstanceState)
//    }
//}





