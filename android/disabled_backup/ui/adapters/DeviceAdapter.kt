package com.zerotechiot.eg.ui.adapters

import com.zerotechiot.eg.ui.models.DeviceModel

class DeviceAdapter(
    private val deviceList: List<DeviceModel>,
    private val listener: OnDeviceClickListener
) {

    interface OnDeviceClickListener {
        fun onDeviceClick(device: Any)
        fun onDeviceToggle(device: Any, isOn: Boolean)
    }
}
