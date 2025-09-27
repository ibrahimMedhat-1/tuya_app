package com.zerotechiot.eg.services

import android.content.Context
import com.zerotechiot.eg.ui.models.DeviceModel

class DeviceControlService(private val context: Context) {

    fun loadRealDevices(callback: DeviceLoadCallback) {
        // Mock data
        val devices = listOf(
            DeviceModel("1", "Living Room Light", "light", true, true),
            DeviceModel("2", "Bedroom Fan", "fan", false, false)
        )
        callback.onSuccess(devices)
    }

    fun toggleDevice(deviceId: String, isOn: Boolean, callback: DeviceToggleCallback) {
        // Mock toggle
        callback.onSuccess(isOn)
    }

    interface DeviceLoadCallback {
        fun onSuccess(realDevices: List<DeviceModel>)
        fun onError(error: String)
    }

    interface DeviceToggleCallback {
        fun onSuccess(newState: Boolean)
        fun onError(error: String)
    }
}
