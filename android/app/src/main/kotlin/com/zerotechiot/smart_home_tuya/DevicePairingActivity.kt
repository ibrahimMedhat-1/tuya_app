package com.zerotechiot.smart_home_tuya

import android.Manifest
import android.content.pm.PackageManager
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.tuya.smart.android.device.bean.DeviceBean
import com.tuya.smart.home.sdk.TuyaHomeSdk
import com.tuya.smart.home.sdk.bean.HomeBean
import com.tuya.smart.home.sdk.callback.ITuyaHomeResultCallback
import com.tuya.smart.sdk.api.ITuyaActivator
import com.tuya.smart.sdk.api.ITuyaActivatorGetToken
import com.tuya.smart.sdk.api.ITuyaDataCallback
import com.tuya.smart.sdk.bean.DeviceBean as ActivatorDeviceBean

/**
 * Android Device Pairing Activity
 * Equivalent to iOS AddDeviceViewController
 * Handles device discovery, pairing, and QR code scanning
 */
class DevicePairingActivity : AppCompatActivity() {
    
    private val TAG = "DevicePairingActivity"
    private val PERMISSION_REQUEST_CODE = 1001
    
    // UI Elements
    private lateinit var recyclerView: RecyclerView
    private lateinit var scanButton: Button
    private lateinit var qrCodeButton: Button
    private lateinit var statusText: TextView
    private lateinit var progressBar: ProgressBar
    private lateinit var homeSpinner: Spinner
    
    // Data
    private var currentHome: HomeBean? = null
    private var homeList: List<HomeBean> = emptyList()
    private var discoveredDevices: List<ActivatorDeviceBean> = emptyList()
    private var isScanning = false
    private var activator: ITuyaActivator? = null
    
    // Adapter
    private lateinit var deviceAdapter: DevicePairingAdapter
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_device_pairing)
        
        setupUI()
        setupRecyclerView()
        loadHomes()
        checkPermissions()
    }
    
    private fun setupUI() {
        title = "Add Device"
        
        // Initialize UI elements
        recyclerView = findViewById(R.id.recyclerView)
        scanButton = findViewById(R.id.scanButton)
        qrCodeButton = findViewById(R.id.qrCodeButton)
        statusText = findViewById(R.id.statusText)
        progressBar = findViewById(R.id.progressBar)
        homeSpinner = findViewById(R.id.homeSpinner)
        
        // Setup buttons
        scanButton.setOnClickListener { startDeviceScanning() }
        qrCodeButton.setOnClickListener { startQRCodeScanning() }
        
        // Setup home spinner
        homeSpinner.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
            override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
                currentHome = homeList[position]
                Log.d(TAG, "Selected home: ${currentHome?.name}")
            }
            
            override fun onNothingSelected(parent: AdapterView<*>?) {}
        }
    }
    
    private fun setupRecyclerView() {
        deviceAdapter = DevicePairingAdapter { device ->
            pairDevice(device)
        }
        
        recyclerView.layoutManager = LinearLayoutManager(this)
        recyclerView.adapter = deviceAdapter
    }
    
    private fun loadHomes() {
        statusText.text = "Loading homes..."
        progressBar.visibility = View.VISIBLE
        
        TuyaHomeSdk.getHomeManagerInstance().queryHomeList(object : ITuyaHomeResultCallback {
            override fun onSuccess(homes: List<HomeBean>) {
                runOnUiThread {
                    homeList = homes
                    progressBar.visibility = View.GONE
                    
                    if (homes.isNotEmpty()) {
                        currentHome = homes[0]
                        setupHomeSpinner()
                        statusText.text = "Select a home and tap 'Scan for Devices'"
                    } else {
                        statusText.text = "No homes found. Please create a home first."
                        scanButton.isEnabled = false
                    }
                }
            }
            
            override fun onError(errorCode: String, errorMessage: String) {
                runOnUiThread {
                    progressBar.visibility = View.GONE
                    statusText.text = "Failed to load homes: $errorMessage"
                    showToast("Error loading homes: $errorMessage")
                }
            }
        })
    }
    
    private fun setupHomeSpinner() {
        val homeNames = homeList.map { it.name }
        val adapter = ArrayAdapter(this, android.R.layout.simple_spinner_item, homeNames)
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
        homeSpinner.adapter = adapter
    }
    
    private fun checkPermissions() {
        val permissions = arrayOf(
            Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.ACCESS_COARSE_LOCATION,
            Manifest.permission.CAMERA,
            Manifest.permission.BLUETOOTH,
            Manifest.permission.BLUETOOTH_ADMIN
        )
        
        val missingPermissions = permissions.filter {
            ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }
        
        if (missingPermissions.isNotEmpty()) {
            ActivityCompat.requestPermissions(this, missingPermissions.toTypedArray(), PERMISSION_REQUEST_CODE)
        }
    }
    
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        
        if (requestCode == PERMISSION_REQUEST_CODE) {
            val allGranted = grantResults.all { it == PackageManager.PERMISSION_GRANTED }
            if (allGranted) {
                statusText.text = "Permissions granted. Ready to scan for devices."
            } else {
                statusText.text = "Some permissions denied. Device discovery may not work properly."
                showToast("Some permissions are required for device discovery")
            }
        }
    }
    
    private fun startDeviceScanning() {
        if (currentHome == null) {
            showToast("Please select a home first")
            return
        }
        
        if (isScanning) {
            stopDeviceScanning()
            return
        }
        
        isScanning = true
        scanButton.text = "Stop Scanning"
        statusText.text = "Scanning for devices..."
        progressBar.visibility = View.VISIBLE
        discoveredDevices = emptyList()
        deviceAdapter.updateDevices(discoveredDevices)
        
        // Get activator token
        TuyaHomeSdk.getActivatorInstance().getActivatorToken(
            currentHome!!.homeId,
            object : ITuyaActivatorGetToken {
                override fun onSuccess(token: String) {
                    Log.d(TAG, "Got activator token: $token")
                    startDeviceDiscovery(token)
                }
                
                override fun onFailure(errorCode: String, errorMsg: String) {
                    runOnUiThread {
                        isScanning = false
                        scanButton.text = "Scan for Devices"
                        progressBar.visibility = View.GONE
                        statusText.text = "Failed to get activator token: $errorMsg"
                        showToast("Failed to start scanning: $errorMsg")
                    }
                }
            }
        )
    }
    
    private fun startDeviceDiscovery(token: String) {
        activator = TuyaHomeSdk.getActivatorInstance().newActivator()
        
        activator?.startDiscovery(
            token,
            object : ITuyaDataCallback<ActivatorDeviceBean> {
                override fun onSuccess(device: ActivatorDeviceBean) {
                    runOnUiThread {
                        val updatedDevices = discoveredDevices.toMutableList()
                        if (!updatedDevices.any { it.devId == device.devId }) {
                            updatedDevices.add(device)
                            discoveredDevices = updatedDevices
                            deviceAdapter.updateDevices(discoveredDevices)
                            statusText.text = "Found ${discoveredDevices.size} device(s). Tap to pair."
                        }
                    }
                }
                
                override fun onFailure(errorCode: String, errorMsg: String) {
                    runOnUiThread {
                        Log.e(TAG, "Device discovery failed: $errorCode - $errorMsg")
                        statusText.text = "Discovery failed: $errorMsg"
                    }
                }
            }
        )
        
        // Stop discovery after 30 seconds
        scanButton.postDelayed({
            stopDeviceScanning()
        }, 30000)
    }
    
    private fun stopDeviceScanning() {
        isScanning = false
        scanButton.text = "Scan for Devices"
        progressBar.visibility = View.GONE
        activator?.stopDiscovery()
        
        if (discoveredDevices.isEmpty()) {
            statusText.text = "No devices found. Make sure devices are in pairing mode."
        } else {
            statusText.text = "Found ${discoveredDevices.size} device(s). Tap to pair."
        }
    }
    
    private fun pairDevice(device: ActivatorDeviceBean) {
        if (currentHome == null) {
            showToast("No home selected")
            return
        }
        
        statusText.text = "Pairing device: ${device.name}"
        progressBar.visibility = View.VISIBLE
        
        // Add device to home
        TuyaHomeSdk.getHomeManagerInstance().addHomeDevice(
            currentHome!!.homeId,
            device.devId,
            device.name,
            object : ITuyaHomeResultCallback {
                override fun onSuccess(home: HomeBean) {
                    runOnUiThread {
                        progressBar.visibility = View.GONE
                        statusText.text = "Device '${device.name}' paired successfully!"
                        showToast("Device '${device.name}' added to your home")
                        
                        // Remove paired device from list
                        val updatedDevices = discoveredDevices.toMutableList()
                        updatedDevices.removeAll { it.devId == device.devId }
                        discoveredDevices = updatedDevices
                        deviceAdapter.updateDevices(discoveredDevices)
                    }
                }
                
                override fun onError(errorCode: String, errorMessage: String) {
                    runOnUiThread {
                        progressBar.visibility = View.GONE
                        statusText.text = "Pairing failed: $errorMessage"
                        showToast("Failed to pair device: $errorMessage")
                    }
                }
            }
        )
    }
    
    private fun startQRCodeScanning() {
        // For now, show a message. In a real implementation, you would integrate a QR code scanner
        showToast("QR Code scanning will be implemented with a camera library")
        statusText.text = "QR Code scanning not yet implemented"
    }
    
    private fun showToast(message: String) {
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show()
    }
    
    override fun onDestroy() {
        super.onDestroy()
        if (isScanning) {
            stopDeviceScanning()
        }
    }
}

/**
 * RecyclerView Adapter for discovered devices
 */
class DevicePairingAdapter(
    private val onDeviceClick: (ActivatorDeviceBean) -> Unit
) : RecyclerView.Adapter<DevicePairingAdapter.DeviceViewHolder>() {
    
    private var devices: List<ActivatorDeviceBean> = emptyList()
    
    fun updateDevices(newDevices: List<ActivatorDeviceBean>) {
        devices = newDevices
        notifyDataSetChanged()
    }
    
    override fun onCreateViewHolder(parent: android.view.ViewGroup, viewType: Int): DeviceViewHolder {
        val view = android.view.LayoutInflater.from(parent.context)
            .inflate(android.R.layout.simple_list_item_2, parent, false)
        return DeviceViewHolder(view)
    }
    
    override fun onBindViewHolder(holder: DeviceViewHolder, position: Int) {
        val device = devices[position]
        holder.bind(device)
    }
    
    override fun getItemCount(): Int = devices.size
    
    inner class DeviceViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        private val text1: TextView = itemView.findViewById(android.R.id.text1)
        private val text2: TextView = itemView.findViewById(android.R.id.text2)
        
        fun bind(device: ActivatorDeviceBean) {
            text1.text = device.name
            text2.text = "Device ID: ${device.devId}\nStatus: ${if (device.isOnline) "Online" else "Offline"}"
            
            itemView.setOnClickListener {
                onDeviceClick(device)
            }
        }
    }
}
