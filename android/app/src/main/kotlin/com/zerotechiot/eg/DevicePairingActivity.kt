package com.zerotechiot.eg

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.util.Log
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

/**
 * DevicePairingActivity - Handles device pairing related activities
 * 
 * Note: This activity is currently not used as the pairing flow
 * is handled entirely in Flutter UI for better control and customization.
 * 
 * This file is kept for potential future native integrations if needed.
 */
class DevicePairingActivity : AppCompatActivity() {
    
    private val TAG = "DevicePairingActivity"
    private val CAMERA_PERMISSION_REQUEST = 1001

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        Log.d(TAG, "DevicePairingActivity created - currently unused")
        Toast.makeText(this, "Device pairing handled in Flutter UI", Toast.LENGTH_SHORT).show()
        finish()
    }
}
