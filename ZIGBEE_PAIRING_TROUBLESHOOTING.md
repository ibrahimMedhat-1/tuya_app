# Zigbee Device Pairing Troubleshooting Guide

## Issue: QR Code Scanned but Device Doesn't Pair

### Problem Description
When scanning a Zigbee device QR code (e.g., smart screen Zigbee), the QR code is scanned successfully but the device doesn't pair and the app returns to the pairing page without doing anything.

### Root Cause
Zigbee devices **must be paired through a gateway as sub-devices**. They cannot be paired directly like Wi-Fi or Bluetooth devices. The BizBundle UI should automatically route to gateway sub-device pairing when a Zigbee QR code is scanned, but this requires:

1. **A Zigbee gateway must be set up in the home first**
2. **The gateway must be online and functioning**
3. **The device must be in pairing mode**

### Solution

#### Option 1: Pair Through Gateway (Recommended)
1. **Ensure Gateway is Set Up:**
   - Open the app
   - Check that you have a Zigbee gateway added to your home
   - Verify the gateway is online

2. **Add Zigbee Device as Sub-Device:**
   - Go to the Zigbee gateway device in the app
   - Tap on the gateway device to open its control panel
   - Look for "Add Sub-Device" or "Add Device" option
   - Put your Zigbee smart screen into pairing mode (press and hold reset button until LED blinks)
   - Tap "Add Sub-Device" and follow the prompts
   - The device should be discovered and paired automatically

#### Option 2: Use QR Code Scan from Gateway
1. **Open Gateway Control Panel:**
   - Navigate to your Zigbee gateway in the app
   - Open the gateway's control panel

2. **Add Sub-Device with QR Code:**
   - Look for "Add Sub-Device" option
   - Select "Scan QR Code" if available
   - Scan the Zigbee device QR code
   - Follow the pairing prompts

#### Option 3: Manual Device Selection
1. **Open Gateway Control Panel:**
   - Navigate to your Zigbee gateway in the app
   - Open the gateway's control panel

2. **Add Sub-Device Manually:**
   - Tap "Add Sub-Device"
   - Put device in pairing mode
   - Wait for device to be discovered
   - Select the device from the list
   - Complete pairing

### Why This Happens

The Tuya BizBundle device pairing UI (`ThingDeviceActivatorManager.startDeviceActiveAction()`) supports multiple device types:
- ✅ **Wi-Fi devices** - Can be paired directly
- ✅ **Bluetooth devices** - Can be paired directly  
- ⚠️ **Zigbee devices** - Must be paired through a gateway as sub-devices

When you scan a Zigbee device QR code from the main pairing UI:
1. The QR code is parsed successfully ✅
2. The device information is extracted ✅
3. The system recognizes it's a Zigbee device ✅
4. **But it needs to route to gateway sub-device pairing** ⚠️
5. If no gateway is available or the routing fails, it returns to the pairing page ❌

### Technical Details

#### How Zigbee Pairing Works
1. **Gateway Required:** Zigbee devices communicate through a Zigbee gateway (hub)
2. **Sub-Device Model:** Zigbee devices are "sub-devices" of the gateway
3. **Pairing Flow:** 
   - Device enters pairing mode
   - Gateway discovers the device
   - Device is bound to the gateway
   - Device appears as a sub-device in the app

#### BizBundle UI Behavior
The `ThingDeviceActivatorManager.startDeviceActiveAction()` method:
- Opens the main device pairing UI
- Supports QR code scanning for all device types
- Should automatically route Zigbee devices to gateway pairing
- **May fail if:**
  - No gateway is set up in the home
  - Gateway is offline
  - Gateway context is not properly initialized

### Verification Steps

1. **Check for Gateways:**
   ```kotlin
   // The app now logs gateway detection
   // Check logs for: "✅ Found X gateway(s) in home"
   ```

2. **Check Device Type:**
   - When scanning QR code, check logs for device type detection
   - Zigbee devices should be identified as gateway sub-devices

3. **Check Gateway Status:**
   - Ensure gateway is online in the app
   - Gateway should show as connected/online

### Workaround

If the automatic routing doesn't work:

1. **Don't use QR code scan from main pairing UI**
2. **Instead:**
   - Go directly to your Zigbee gateway device
   - Open the gateway control panel
   - Use "Add Sub-Device" option
   - Put device in pairing mode
   - Device will be discovered and paired

### Future Improvements

The implementation now includes:
- ✅ Gateway detection and logging
- ✅ Home context verification before pairing
- ✅ Better error messages for Zigbee devices
- ✅ Logging to help diagnose pairing issues

### Logs to Check

When pairing a Zigbee device, check logs for:
```
✅ Current home ID: [homeId]
✅ Found X gateway(s) in home - Zigbee devices can be paired
✅ BizBundle device pairing UI started successfully
✅ Zigbee sub-device pairing supported (requires gateway)
```

If you see:
```
⚠️ No gateways found in home
⚠️ Note: Zigbee devices require a gateway to be paired as sub-devices
```

Then you need to set up a gateway first before pairing Zigbee devices.

### References

- Tuya Zigbee Device Pairing: https://support.tuya.com/en/help/_detail/Kdnct7w1tfz20
- Tuya Gateway Setup: https://support.tuya.com/en/help/_detail/K94zykn9ms1gg
- Device Pairing UI BizBundle Documentation


