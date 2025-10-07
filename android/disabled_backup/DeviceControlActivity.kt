package com.zerotechiot.eg

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.widget.Toolbar
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout
import com.bumptech.glide.Glide
import com.google.android.material.card.MaterialCardView
import com.google.android.material.chip.Chip
import com.thingclips.smart.api.MicroContext
import com.thingclips.smart.api.service.MicroServiceManager
import com.thingclips.smart.commonbiz.bizbundle.family.api.AbsBizBundleFamilyService
import com.thingclips.smart.home.sdk.ThingHomeSdk
import com.thingclips.smart.home.sdk.bean.HomeBean
import com.thingclips.smart.home.sdk.callback.IThingHomeResultCallback
import com.thingclips.smart.panelcaller.api.AbsPanelCallerService
import com.thingclips.smart.sdk.bean.DeviceBean
import com.zerotechiot.eg.services.DeviceControlService

class DeviceControlActivity : AppCompatActivity() {

    companion object {
        private const val TAG = "DeviceControlActivity"
    }

    // Views
    private lateinit var recyclerView: RecyclerView
    private lateinit var swipeRefreshLayout: SwipeRefreshLayout

    // Data
    private lateinit var adapter: DeviceAdapter
    private lateinit var deviceControlService: DeviceControlService
    private var panelCallerService: AbsPanelCallerService? = null
    private var familyService: AbsBizBundleFamilyService? = null
    private val deviceList = mutableListOf<DeviceBean>()
    private var currentHomeId: Long = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_device_control)

        initializeServices()
        setupViews()
        loadDevices()
    }

    private fun initializeServices() {
        try {
            // Initialize device control service
            deviceControlService = DeviceControlService(this)

            // Initialize panel caller service
            panelCallerService = MicroContext.getServiceManager()
                ?.findServiceByInterface(AbsPanelCallerService::class.java.name)

            // Get family service
            familyService = MicroServiceManager.getInstance()
                ?.findServiceByInterface(AbsBizBundleFamilyService::class.java.name)

        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize services", e)
        }
    }

    private fun setupViews() {
        // Setup toolbar
        val toolbar: Toolbar = findViewById(R.id.toolbar)
        setSupportActionBar(toolbar)
        supportActionBar?.apply {
            title = "Device Control"
            setDisplayHomeAsUpEnabled(true)
        }

        // Setup swipe refresh
        swipeRefreshLayout = findViewById(R.id.swipeRefreshLayout)
        swipeRefreshLayout.setColorSchemeResources(
            android.R.color.holo_blue_bright,
            android.R.color.holo_green_light,
            android.R.color.holo_orange_light,
            android.R.color.holo_red_light
        )
        swipeRefreshLayout.setOnRefreshListener { loadDevices() }

        // Setup recycler view
        recyclerView = findViewById(R.id.recyclerView)
        recyclerView.layoutManager = LinearLayoutManager(this)
        adapter = DeviceAdapter()
        recyclerView.adapter = adapter
    }

    private fun loadDevices() {
        familyService?.let { service ->
            currentHomeId = service.currentHomeId
            if (currentHomeId == 0L) {
                Toast.makeText(this, "No home selected", Toast.LENGTH_SHORT).show()
                swipeRefreshLayout.isRefreshing = false
                return
            }

            swipeRefreshLayout.isRefreshing = true

            ThingHomeSdk.newHomeInstance(currentHomeId).getHomeDetail(object : IThingHomeResultCallback {
                override fun onSuccess(homeBean: HomeBean?) {
                    homeBean?.deviceList?.let { devices ->
                        deviceList.clear()
                        deviceList.addAll(devices)

                        runOnUiThread {
                            adapter.notifyDataSetChanged()
                            swipeRefreshLayout.isRefreshing = false

                            if (deviceList.isEmpty()) {
                                Toast.makeText(
                                    this@DeviceControlActivity,
                                    "No devices found. Add devices to your home first.",
                                    Toast.LENGTH_LONG
                                ).show()
                            }
                        }
                    } ?: run {
                        runOnUiThread {
                            swipeRefreshLayout.isRefreshing = false
                            Toast.makeText(
                                this@DeviceControlActivity,
                                "No devices found in this home",
                                Toast.LENGTH_SHORT
                            ).show()
                        }
                    }
                }

                override fun onError(code: String?, error: String?) {
                    Log.e(TAG, "Failed to load devices: $code - $error")
                    runOnUiThread {
                        swipeRefreshLayout.isRefreshing = false
                        Toast.makeText(
                            this@DeviceControlActivity,
                            "Failed to load devices: $error",
                            Toast.LENGTH_SHORT
                        ).show()
                    }
                }
            })
        } ?: run {
            Toast.makeText(this, "Family service not available", Toast.LENGTH_SHORT).show()
            swipeRefreshLayout.isRefreshing = false
        }
    }

    private inner class DeviceAdapter : RecyclerView.Adapter<DeviceAdapter.DeviceViewHolder>() {

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): DeviceViewHolder {
            val view = LayoutInflater.from(parent.context)
                .inflate(R.layout.item_device_control, parent, false)
            return DeviceViewHolder(view)
        }

        override fun onBindViewHolder(holder: DeviceViewHolder, position: Int) {
            val device = deviceList[position]
            holder.bind(device)
        }

        override fun getItemCount(): Int = deviceList.size

        inner class DeviceViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
            private val cardView: MaterialCardView = itemView.findViewById(R.id.deviceCard)
            private val deviceIcon: ImageView = itemView.findViewById(R.id.deviceIcon)
            private val deviceName: TextView = itemView.findViewById(R.id.deviceName)
            private val deviceStatus: TextView = itemView.findViewById(R.id.deviceStatus)
            private val deviceType: Chip = itemView.findViewById(R.id.deviceType)
            private val onlineStatus: Chip = itemView.findViewById(R.id.onlineStatus)

            fun bind(device: DeviceBean) {
                // Set device name
                deviceName.text = device.name

                // Set device status
                if (device.isOnline) {
                    deviceStatus.text = "Online"
                    onlineStatus.text = "Online"
                } else {
                    deviceStatus.text = "Offline"
                    onlineStatus.text = "Offline"
                }

                // Set device type
                val deviceTypeText = getDeviceTypeName(device.productId)
                deviceType.text = deviceTypeText

                // Load device icon using Glide
                if (!device.iconUrl.isNullOrEmpty()) {
                    Glide.with(itemView.context)
                        .load(device.iconUrl)
                        .placeholder(R.drawable.ic_device)
                        .error(R.drawable.ic_device)
                        .into(deviceIcon)
                } else {
                    deviceIcon.setImageResource(R.drawable.ic_device)
                }

                cardView.setOnClickListener {
                    if (device.isOnline) {
                        launchDeviceControl(device.devId)
                    } else {
                        Toast.makeText(
                            this@DeviceControlActivity,
                            "Device is offline",
                            Toast.LENGTH_SHORT
                        ).show()
                    }
                }
            }

            private fun getDeviceTypeName(productId: String?): String {
                if (productId == null) return "Unknown"

                val lowerProductId = productId.lowercase()
                return when {
                    lowerProductId.contains("light") || lowerProductId.contains("bulb") -> "Light"
                    lowerProductId.contains("switch") || lowerProductId.contains("outlet") -> "Switch"
                    lowerProductId.contains("lock") -> "Lock"
                    lowerProductId.contains("camera") || lowerProductId.contains("ipc") -> "Camera"
                    lowerProductId.contains("sensor") -> "Sensor"
                    lowerProductId.contains("thermostat") -> "Thermostat"
                    lowerProductId.contains("curtain") -> "Curtain"
                    lowerProductId.contains("fan") -> "Fan"
                    lowerProductId.contains("vacuum") || lowerProductId.contains("sweeper") -> "Vacuum"
                    else -> "Device"
                }
            }
        }
    }

    private fun launchDeviceControl(deviceId: String) {
        panelCallerService?.let { service ->
            Log.d(TAG, "Launching device control panel for device: $deviceId")
            service.goPanelWithCheckAndTip(this, deviceId)
        } ?: run {
            Toast.makeText(
                this,
                "Device control panel service not available. Please ensure Panel BizBundle is included.",
                Toast.LENGTH_LONG
            ).show()
            Log.e(TAG, "PanelCallerService is null. Cannot launch panel.")
        }
    }

    override fun onSupportNavigateUp(): Boolean {
        onBackPressedDispatcher.onBackPressed()
        return true
    }

    override fun onDestroy() {
        super.onDestroy()
        // Device control service cleanup is handled automatically if it implements any lifecycle interfaces
    }
}
