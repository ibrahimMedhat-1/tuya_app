package com.zerotechiot.eg.ui.models

data class DeviceModel(
    val id: String,
    val name: String,
    val type: String,
    var isOnline: Boolean,
    var isOn: Boolean
)
