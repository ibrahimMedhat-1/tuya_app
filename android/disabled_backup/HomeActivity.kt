package com.zerotechiot.eg

import android.content.ActivityNotFoundException
import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.google.android.material.bottomnavigation.BottomNavigationView
import com.google.android.material.floatingactionbutton.FloatingActionButton
import com.google.android.material.snackbar.Snackbar
import com.zerotechiot.eg.services.DeviceControlService
import com.zerotechiot.eg.ui.adapters.DeviceAdapter
import com.zerotechiot.eg.ui.models.DeviceModel

/**
 * Modern Home Activity with enhanced UX features
 * Integrates Tuya SDK for device management and control
 */
class HomeActivity : AppCompatActivity(), DeviceAdapter.OnDeviceClickListener {

    companion object {
        private const val TAG = "HomeActivity"
        private const val REQUEST_PAIR_DEVICE = 1001
    }

    // Views
    private lateinit var devicesRecyclerView: RecyclerView
    private lateinit var welcomeText: TextView
    private lateinit var statusOverview: TextView
    private lateinit var emptyState: View
    private lateinit var bottomNavigation: BottomNavigationView
    private lateinit var fabAddDevice: FloatingActionButton

    // Data
    private val deviceList = mutableListOf<DeviceModel>()
    private var currentHomeId: Long = -1
    private lateinit var deviceControlService: DeviceControlService

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_home)

        // Initialize device control service
        deviceControlService = DeviceControlService(this)

        initViews()
        setupNavigation()
        setupRecyclerView()
        loadHomeData()
        setupClickListeners()
    }

    private fun initViews() {
        devicesRecyclerView = findViewById(R.id.devices_recycler_view)
        welcomeText = findViewById(R.id.welcome_text)
        statusOverview = findViewById(R.id.status_overview)
        emptyState = findViewById(R.id.empty_state)
        bottomNavigation = findViewById(R.id.bottom_navigation)
        fabAddDevice = findViewById(R.id.fab_add_device)
    }

    private fun setupNavigation() {
        bottomNavigation.setOnItemSelectedListener { item ->
            when (item.itemId) {
                R.id.nav_home -> {
                    // Already on home
                    true
                }
                R.id.nav_rooms -> {
                    // Navigate to device management
                    val intent = Intent(this, MainActivity::class.java)
                    startActivity(intent)
                    true
                }
                R.id.nav_scenes -> {
                    // Navigate to scenes
                    val intent = Intent(this, com.thingclips.smart.bizbundle.scene.demo.SceneActivity::class.java)
                    startActivity(intent)
                    true
                }
                R.id.nav_automation -> {
                    // Navigate to automation
                    Toast.makeText(this, "Automation coming soon", Toast.LENGTH_SHORT).show()
                    true
                }
                R.id.nav_profile -> {
                    // Navigate to profile
                    Toast.makeText(this, "Profile coming soon", Toast.LENGTH_SHORT).show()
                    true
                }
                else -> false
            }
        }
    }

    private fun setupRecyclerView() {
        devicesRecyclerView.layoutManager = LinearLayoutManager(this)
        val adapter = DeviceAdapter(deviceList, this)
        devicesRecyclerView.adapter = adapter
    }

    private fun loadHomeData() {
        Log.d(TAG, "Loading real devices from Tuya SDK...")

        // Load real devices from Tuya SDK
        deviceControlService.loadRealDevices(object : DeviceControlService.DeviceLoadCallback {
            override fun onSuccess(realDevices: List<DeviceModel>) {
                runOnUiThread {
                    Log.d(TAG, "Successfully loaded ${realDevices.size} real devices")
                    deviceList.clear()
                    deviceList.addAll(realDevices)
                    updateDeviceList()
                    updateStatusOverview(realDevices.size)

                    if (realDevices.isEmpty()) {
                        showEmptyState()
                        showSnackbar("No devices found. Add some devices to get started!")
                    } else {
                        hideEmptyState()
                        showSnackbar("Loaded ${realDevices.size} real devices")
                    }
                }
            }

            override fun onError(error: String) {
                runOnUiThread {
                    Log.e(TAG, "Failed to load real devices: $error")
                    showError("Failed to load devices: $error")
                    showEmptyState()
                }
            }
        })
    }

    private fun updateDeviceList() {
        runOnUiThread {
            // Create and set up device adapter
            val deviceAdapter = DeviceAdapter(deviceList, this)
            devicesRecyclerView.adapter = deviceAdapter

            if (deviceList.isEmpty()) {
                showEmptyState()
            } else {
                hideEmptyState()
            }
        }
    }

    private fun updateStatusOverview(deviceCount: Int) {
        runOnUiThread {
            val onlineCount = deviceList.count { it.isOnline }
            statusOverview.text = "$onlineCount devices online • $deviceCount total devices"
        }
    }

    private fun showEmptyState() {
        runOnUiThread {
            emptyState.visibility = View.VISIBLE
            devicesRecyclerView.visibility = View.GONE
        }
    }

    private fun hideEmptyState() {
        runOnUiThread {
            emptyState.visibility = View.GONE
            devicesRecyclerView.visibility = View.VISIBLE
        }
    }

    private fun setupClickListeners() {
        fabAddDevice.setOnClickListener {
            startDevicePairing()
        }
    }

    private fun startDevicePairing() {
        try {
            val intent = Intent(this, DevicePairingActivity::class.java)
            startActivityForResult(intent, REQUEST_PAIR_DEVICE)
        } catch (e: ActivityNotFoundException) {
            Toast.makeText(
                this,
                "Device Pairing feature is not available in this build.",
                Toast.LENGTH_LONG
            ).show()
            e.printStackTrace()
        }
    }

    private fun showComingSoon(feature: String) {
        Snackbar.make(
            findViewById(android.R.id.content),
            "$feature coming soon!",
            Snackbar.LENGTH_SHORT
        ).show()
    }

    private fun showSnackbar(message: String) {
        Snackbar.make(
            findViewById(android.R.id.content),
            message,
            Snackbar.LENGTH_SHORT
        ).show()
    }

    private fun showError(message: String) {
        Snackbar.make(
            findViewById(android.R.id.content),
            message,
            Snackbar.LENGTH_LONG
        ).show()
    }

    override fun onResume() {
        super.onResume()
        // Refresh device list when returning to the activity
        loadHomeData()
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_PAIR_DEVICE) {
            if (resultCode == RESULT_OK) {
                showSnackbar("Device paired successfully!")
                loadHomeData() // Refresh the device list
            } else {
                showSnackbar("Device pairing cancelled or failed")
            }
        }
    }

    override fun onDeviceClick(device: Any) {
        if (device is DeviceModel) {
            Log.d(TAG, "Device clicked: ${device.name} (ID: ${device.id})")

            // Launch device control activity with real device data
            val intent = Intent(this, DeviceControlActivity::class.java).apply {
                putExtra("device_id", device.id)
                putExtra("device_name", device.name)
                putExtra("device_type", device.type)
            }
            startActivity(intent)
        }
    }

    override fun onDeviceToggle(device: Any, isOn: Boolean) {
        if (device is DeviceModel) {
            Log.d(TAG, "Toggling device ${device.name} to ${if (isOn) "ON" else "OFF"}")

            // Use device control service to toggle real device
            deviceControlService.toggleDevice(
                device.id,
                isOn,
                object : DeviceControlService.DeviceToggleCallback {
                    override fun onSuccess(newState: Boolean) {
                        runOnUiThread {
                            device.isOn = newState
                            showSnackbar("${device.name} turned ${if (newState) "ON" else "OFF"}")
                            // Update the adapter to reflect the change
                            updateDeviceList()
                        }
                    }

                    override fun onError(error: String) {
                        runOnUiThread {
                            Log.e(TAG, "Failed to toggle device: $error")
                            showError("Failed to toggle ${device.name}: $error")
                            // Revert the toggle in the UI
                            device.isOn = !isOn
                            updateDeviceList()
                        }
                    }
                }
            )
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        // Device control service cleanup is handled automatically
    }
}
