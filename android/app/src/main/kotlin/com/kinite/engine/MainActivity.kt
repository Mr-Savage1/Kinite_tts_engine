package com.kinite.engine

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        try {
            // Load in the specific order required by Sherpa
            System.loadLibrary("onnxruntime")
            System.loadLibrary("sherpa-onnx-c-api")
        } catch (e: Exception) {
            android.util.Log.e("REXA", "Native lib load failed: ${e.message}")
        }
        super.onCreate(savedInstanceState)
    } // Ensure this closing brace is present!
}
