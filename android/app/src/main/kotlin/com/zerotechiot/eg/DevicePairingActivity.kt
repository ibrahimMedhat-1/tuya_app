package com.zerotechiot.eg

import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.widget.Toolbar

class DevicePairingActivity : AppCompatActivity() {

    private lateinit var statusText: TextView
    private lateinit var retryButton: Button
    private lateinit var backButton: Button
    private lateinit var manualButton: Button
    private lateinit var scanQrButton: Button

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_device_pairing)

        // Setup toolbar
        val toolbar: Toolbar = findViewById(R.id.toolbar)
        setSupportActionBar(toolbar)
        supportActionBar?.apply {
            setDisplayHomeAsUpEnabled(true)
            title = "Add Device"
        }

        // Initialize views
        statusText = findViewById(R.id.status_text)
        retryButton = findViewById(R.id.retry_button)
        backButton = findViewById(R.id.back_button)
        manualButton = findViewById(R.id.manual_button)
        scanQrButton = findViewById(R.id.scan_qr_button)

        // Setup click listeners
        retryButton.setOnClickListener { attemptDevicePairing() }
        backButton.setOnClickListener { finish() }
        manualButton.setOnClickListener { showManualInstructions() }
        scanQrButton.setOnClickListener {
            // Placeholder for Tuya SDK QR Code Scanning logic
            Toast.makeText(this, "QR Scan button clicked!", Toast.LENGTH_SHORT).show()
            // TODO: 1. Check/Request Camera Permissions
            // TODO: 2. Initialize and start Tuya QR Code Scanner
            // TODO: 3. Handle scan result (token) from Tuya SDK
            // TODO: 4. Use the token to provision the device via Tuya SDK
        }

        // Initial attempt (or remove if QR scan is the primary method now)
        attemptDevicePairing()
    }

    private fun attemptDevicePairing() {
        statusText.text = "Attempting to connect to device pairing service..."
        retryButton.visibility = View.GONE
        manualButton.visibility = View.GONE
        scanQrButton.visibility = View.VISIBLE // Make sure QR button is visible if this is a fallback

        try {
            // Try to launch the BizBundle's DeviceActivatorActivity
            val intent = Intent().apply {
                setClassName(this@DevicePairingActivity, "com.tuya.smart.bizbundle.activator.demo.DeviceActivatorActivity")
            }
            startActivity(intent)
            finish() // Finish this activity if Tuya's activity is launched
        } catch (e: Exception) {
            // If the activator activity is not available, show a message
            statusText.text = """
                Device pairing service is not available in this demo version.
                
                Please use the Tuya Smart app for device pairing, try the manual setup option, or use QR Scan.
            """
                .trimIndent()

            retryButton.visibility = View.VISIBLE
            retryButton.text = "Try Auto Pairing"
            manualButton.visibility = View.VISIBLE
            scanQrButton.visibility = View.VISIBLE // Ensure QR button is visible

            // Log the error for debugging
            e.printStackTrace()
        }
    }

    private fun showManualInstructions() {
        statusText.text = """
            Manual Device Setup Instructions:
            
            1. Make sure your device is in pairing mode
            2. Connect to the device's WiFi network
            3. Open the Tuya Smart app
            4. Follow the app's pairing instructions
            
            Note: This demo version has limited pairing capabilities.
        """
            .trimIndent()

        retryButton.visibility = View.VISIBLE
        retryButton.text = "Try Auto Pairing"
        manualButton.visibility = View.GONE
        scanQrButton.visibility = View.VISIBLE // Ensure QR button is visible
    }

    override fun onSupportNavigateUp(): Boolean {
        onBackPressedDispatcher.onBackPressed()
        return true
    }
}
