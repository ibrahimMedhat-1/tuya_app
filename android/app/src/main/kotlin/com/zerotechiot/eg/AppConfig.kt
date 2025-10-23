package com.zerotechiot.eg

import androidx.annotation.Keep

/**
 * Application layer configuration for Tuya BizBundle
 * This is required by PackConfig.addValueDelegate() in TuyaSmartApplication
 */
@Keep
object AppConfig {
    /**
     * Switch for dark mode support in theme color
     */
    const val is_darkMode_support = true
    
    /**
     * Switch for Huawei package support
     */
    const val is_huawei_pkg = false
    
    /**
     * List of hotspot prefixes supported for AP mode
     */
    const val ap_mode_ssid = "SmartLife"
    
    /**
     * Whether to support Bluetooth device pairing
     */
    const val is_need_ble_support = true
    
    /**
     * Whether to support Bluetooth Mesh device pairing
     */
    const val is_need_blemesh_support = true
    
    /**
     * Whether to support scan pairing in the top right corner of the list page
     */
    const val is_scan_support = true
}


