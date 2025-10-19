# iOS BizBundle Integration - Flow Diagrams

## 🎨 Visual Flow Diagrams

### 1. Device Control Panel Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         FLUTTER LAYER                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  User Clicks Device Card                                         │
│         ↓                                                         │
│  DeviceCard Widget                                               │
│         ↓                                                         │
│  _openDeviceControlPanel()                                       │
│         ↓                                                         │
│  MethodChannel Call:                                             │
│    - Method: 'openDeviceControlPanel'                            │
│    - Args: { deviceId, homeId, homeName }                        │
│                                                                   │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         │ Platform Channel
                         │
┌────────────────────────┴────────────────────────────────────────┐
│                      iOS NATIVE LAYER                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  AppDelegate receives call                                       │
│         ↓                                                         │
│  methodChannel.setMethodCallHandler                              │
│         ↓                                                         │
│  TuyaBridge.handleMethodCall()                                   │
│         ↓                                                         │
│  TuyaBridge.openDeviceControlPanel()                             │
│         ↓                                                         │
│  ┌─────────────────────────────────────┐                        │
│  │ 1. Verify user is logged in         │                        │
│  │ 2. Get device by deviceId           │                        │
│  │ 3. Set current family ID (homeId)   │                        │
│  │ 4. Ensure main thread               │                        │
│  └─────────────────┬───────────────────┘                        │
│                    │                                              │
│                    ↓                                              │
│  Get BizBundle Service:                                          │
│    ThingSmartBizCore.service(ThingPanelProtocol.self)           │
│                    ↓                                              │
│  Call BizBundle Method:                                          │
│    panelService.gotoPanelViewController(...)                     │
│                                                                   │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         │ BizBundle presents UI
                         │
┌────────────────────────┴────────────────────────────────────────┐
│                     TUYA BIZBUNDLE UI                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  BizBundle queries for context:                                  │
│    TuyaProtocolHandler.getCurrentHome()                          │
│         ↓                                                         │
│  Device Control Panel Opens                                      │
│         ↓                                                         │
│  ┌───────────────────────────────────┐                          │
│  │ • Device Name & Status            │                          │
│  │ • On/Off Switches                 │                          │
│  │ • Brightness/Color Sliders        │                          │
│  │ • Device Settings                 │                          │
│  │ • Schedule/Timer Options          │                          │
│  └───────────────────────────────────┘                          │
│         ↓                                                         │
│  User interacts with controls                                    │
│         ↓                                                         │
│  Device state updates in real-time                               │
│         ↓                                                         │
│  User closes panel (swipe down/back)                             │
│                                                                   │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         │ Returns to Flutter
                         │
┌────────────────────────┴────────────────────────────────────────┐
│                       BACK TO FLUTTER                            │
│                                                                   │
│  HomeScreen displays                                             │
│  Device state updated                                            │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

### 2. Device Pairing Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         FLUTTER LAYER                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  User Clicks "Add Device" FAB                                    │
│         ↓                                                         │
│  HomeScreen Widget                                               │
│         ↓                                                         │
│  context.read<HomeCubit>().pairDevices()                         │
│         ↓                                                         │
│  HomeCubit.pairDevices()                                         │
│         ↓                                                         │
│  TuyaHomeDataSource.pairDevices()                                │
│         ↓                                                         │
│  MethodChannel Call:                                             │
│    - Method: 'pairDevices'                                       │
│    - Args: none                                                  │
│                                                                   │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         │ Platform Channel
                         │
┌────────────────────────┴────────────────────────────────────────┐
│                      iOS NATIVE LAYER                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  AppDelegate receives call                                       │
│         ↓                                                         │
│  methodChannel.setMethodCallHandler                              │
│         ↓                                                         │
│  TuyaBridge.handleMethodCall()                                   │
│         ↓                                                         │
│  TuyaBridge.pairDevices()                                        │
│         ↓                                                         │
│  ┌─────────────────────────────────────┐                        │
│  │ 1. Verify user is logged in         │                        │
│  │ 2. Ensure current home is set       │                        │
│  │ 3. Ensure main thread               │                        │
│  └─────────────────┬───────────────────┘                        │
│                    │                                              │
│                    ↓                                              │
│  Get BizBundle Service:                                          │
│    ThingSmartBizCore.service(ThingActivatorProtocol.self)       │
│                    ↓                                              │
│  Call BizBundle Method:                                          │
│    activatorService.gotoCategoryViewController()                 │
│                                                                   │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         │ BizBundle presents UI
                         │
┌────────────────────────┴────────────────────────────────────────┐
│                     TUYA BIZBUNDLE UI                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  Device Category Selection Opens                                 │
│         ↓                                                         │
│  ┌───────────────────────────────────┐                          │
│  │ Device Categories:                │                          │
│  │  • Lighting (💡)                  │                          │
│  │  • Electrical (🔌)                │                          │
│  │  • Security (🔒)                  │                          │
│  │  • Large Appliances (🏠)          │                          │
│  │  • Small Appliances (☕)          │                          │
│  │  • More Categories...             │                          │
│  └───────────────────────────────────┘                          │
│         ↓                                                         │
│  User selects a category                                         │
│         ↓                                                         │
│  ┌───────────────────────────────────┐                          │
│  │ Pairing Mode Selection:           │                          │
│  │  • Wi-Fi (EZ Mode)                │                          │
│  │  • Wi-Fi (AP Mode)                │                          │
│  │  • Bluetooth                      │                          │
│  │  • Zigbee/Thread                  │                          │
│  └───────────────────────────────────┘                          │
│         ↓                                                         │
│  User selects pairing mode                                       │
│         ↓                                                         │
│  ┌───────────────────────────────────┐                          │
│  │ Pairing Instructions:             │                          │
│  │  1. Power on your device          │                          │
│  │  2. Wait for blinking light       │                          │
│  │  3. Confirm device is in pairing  │                          │
│  │  4. Enter Wi-Fi credentials       │                          │
│  └───────────────────────────────────┘                          │
│         ↓                                                         │
│  Device Discovery & Pairing                                      │
│         ↓                                                         │
│  ┌───────────────────────────────────┐                          │
│  │ • Searching for devices...        │                          │
│  │ • Found device!                   │                          │
│  │ • Connecting...                   │                          │
│  │ • Activating...                   │                          │
│  │ • Success! ✅                     │                          │
│  └───────────────────────────────────┘                          │
│         ↓                                                         │
│  User closes pairing UI                                          │
│                                                                   │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         │ Returns to Flutter
                         │
┌────────────────────────┴────────────────────────────────────────┐
│                       BACK TO FLUTTER                            │
│                                                                   │
│  HomeScreen displays                                             │
│  New device appears in device list                               │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

### 3. BizBundle Home Context Query Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                     BIZBUNDLE NEEDS CONTEXT                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  BizBundle UI Component initializes                              │
│         ↓                                                         │
│  Needs to know which home to operate in                          │
│         ↓                                                         │
│  Queries registered protocol:                                    │
│    ThingSmartHomeDataProtocol.getCurrentHome()                   │
│                                                                   │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         │ Protocol call
                         │
┌────────────────────────┴────────────────────────────────────────┐
│                   TUYAPROTOCOLHANDLER                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  TuyaProtocolHandler.getCurrentHome()                            │
│         ↓                                                         │
│  ┌─────────────────────────────────────┐                        │
│  │ 1. Check UserDefaults for stored ID │                        │
│  │ 2. If found, return that home       │                        │
│  │ 3. If not, get first home from list │                        │
│  │ 4. Store for future use             │                        │
│  │ 5. Return home object               │                        │
│  └─────────────────┬───────────────────┘                        │
│                    │                                              │
│                    ↓                                              │
│  Returns ThingSmartHome object                                   │
│                                                                   │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         │ Home context returned
                         │
┌────────────────────────┴────────────────────────────────────────┐
│                     BIZBUNDLE HAS CONTEXT                        │
│                                                                   │
│  BizBundle UI now knows:                                         │
│    • Which home to operate in                                    │
│    • Which devices belong to this home                           │
│    • Where to save new devices                                   │
│                                                                   │
│  Can proceed with device control/pairing                         │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

### 4. Component Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         FLUTTER APP                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ HomeScreen   │  │ DeviceCard   │  │  HomeCubit   │          │
│  │              │  │              │  │              │          │
│  │ - Add Device │  │ - Device tap │  │ - Business   │          │
│  │   button     │  │   handler    │  │   logic      │          │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘          │
│         │                 │                 │                    │
│         └─────────────────┴─────────────────┘                    │
│                           │                                       │
│                           ↓                                       │
│                  MethodChannel                                    │
│              'com.zerotechiot.eg/tuya_sdk'                       │
│                                                                   │
└────────────────────────────┬──────────────────────────────────┘
                             │
═════════════════════════════╪════════════════════════════════════
                             │ Platform Boundary
═════════════════════════════╪════════════════════════════════════
                             │
┌────────────────────────────┴──────────────────────────────────┐
│                      iOS NATIVE CODE                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    AppDelegate                            │  │
│  │                                                            │  │
│  │  • Stores FlutterViewController                           │  │
│  │  • Initializes Tuya SDK                                   │  │
│  │  • Registers BizBundle protocols                          │  │
│  │  • Sets up MethodChannel                                  │  │
│  └────────────────────────┬─────────────────────────────────┘  │
│                            │                                     │
│                            ↓                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                     TuyaBridge                            │  │
│  │                                                            │  │
│  │  • handleMethodCall() dispatcher                          │  │
│  │  • openDeviceControlPanel()                               │  │
│  │  • pairDevices()                                          │  │
│  │  • ensureCurrentHomeIsSet()                               │  │
│  └────────────────────────┬─────────────────────────────────┘  │
│                            │                                     │
│         ┌──────────────────┴──────────────────┐                │
│         │                                      │                │
│         ↓                                      ↓                │
│  ┌─────────────────┐              ┌──────────────────────┐     │
│  │TuyaProtocol     │              │ ThingSmartBizCore    │     │
│  │Handler          │              │                      │     │
│  │                 │              │ • service(of:)       │     │
│  │• getCurrentHome │              │ • registerService    │     │
│  │• setCurrentHome │              │                      │     │
│  └─────────────────┘              └──────────────────────┘     │
│                                                                  │
└────────────────────────────┬───────────────────────────────────┘
                             │
                             ↓
┌────────────────────────────┴───────────────────────────────────┐
│                      TUYA BIZBUNDLE SDK                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────────────┐  ┌──────────────────────────┐        │
│  │ ThingPanelProtocol   │  │ ThingActivatorProtocol   │        │
│  │                      │  │                          │        │
│  │ gotoPanelView        │  │ gotoCategory             │        │
│  │ Controller()         │  │ ViewController()         │        │
│  │                      │  │                          │        │
│  │ → Device Control     │  │ → Device Pairing         │        │
│  │   Panel UI           │  │   UI                     │        │
│  └──────────────────────┘  └──────────────────────────┘        │
│                                                                   │
│  Native iOS ViewControllers presented modally                    │
│  on top of Flutter view                                          │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

### 5. Threading Model

```
┌─────────────────────────────────────────────────────────────────┐
│                    THREADING DIAGRAM                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  Flutter UI Thread                                               │
│         │                                                         │
│         │ MethodChannel call                                     │
│         │                                                         │
│         ↓                                                         │
│  ═══════════════════════════════════════════════════════════    │
│  Platform Channel (crosses thread boundary)                      │
│  ═══════════════════════════════════════════════════════════    │
│         │                                                         │
│         ↓                                                         │
│  iOS Main Thread (auto by Flutter)                              │
│         │                                                         │
│         ↓                                                         │
│  AppDelegate.methodCallHandler                                   │
│         │                                                         │
│         ↓                                                         │
│  TuyaBridge.handleMethodCall                                     │
│         │                                                         │
│         ↓                                                         │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ DispatchQueue.main.async {                              │   │
│  │    // Ensure we're on main thread for UI operations     │   │
│  │                                                           │   │
│  │    Get BizBundle Service                                 │   │
│  │           ↓                                               │   │
│  │    Call gotoPanelViewController() or                     │   │
│  │    gotoCategoryViewController()                          │   │
│  │           ↓                                               │   │
│  │    BizBundle presents UI modally                         │   │
│  │ }                                                         │   │
│  └───────────────────────────────────────────────────────────┘   │
│         │                                                         │
│         ↓                                                         │
│  iOS Main Thread                                                 │
│  (BizBundle UI runs here)                                        │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘

Key Points:
✅ All UI operations MUST run on main thread
✅ DispatchQueue.main.async ensures proper threading
✅ BizBundle ViewControllers present on main thread
✅ No thread safety issues
```

### 6. State Management

```
┌─────────────────────────────────────────────────────────────────┐
│                    CURRENT HOME STATE                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  UserDefaults.standard                                           │
│         ↓                                                         │
│  Key: "currentHomeId"                                            │
│  Value: Int64 (home ID)                                          │
│         ↓                                                         │
│  Managed by TuyaProtocolHandler                                  │
│         ↓                                                         │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ setCurrentHomeId(homeId)                                 │   │
│  │    → Stores in UserDefaults                              │   │
│  │    → Sets ThingSmartFamilyBiz.currentFamilyId            │   │
│  │                                                           │   │
│  │ getCurrentHomeId()                                        │   │
│  │    → Reads from UserDefaults                             │   │
│  │    → Falls back to first home if not set                 │   │
│  │                                                           │   │
│  │ clearCurrentHomeId()                                      │   │
│  │    → Removes from UserDefaults                           │   │
│  │    → Called on logout                                    │   │
│  └───────────────────────────────────────────────────────────┘   │
│                                                                   │
│  When is it set?                                                 │
│    • When user selects home in dropdown                          │
│    • When loading devices for a home                             │
│    • Before opening device control panel                         │
│    • Before opening device pairing UI                            │
│                                                                   │
│  Why is it needed?                                               │
│    • BizBundle needs to know current home context                │
│    • Devices must be associated with correct home                │
│    • Control panels need home-specific data                      │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔑 Key Takeaways

1. **Platform Channel**: Bridge between Flutter and iOS
2. **AppDelegate**: Stores FlutterViewController, initializes SDK
3. **TuyaBridge**: Handles method calls, manages BizBundle services
4. **TuyaProtocolHandler**: Provides home context to BizBundle
5. **BizBundle Services**: Native UI components from Tuya
6. **Main Thread**: All UI operations must run here
7. **Current Home**: Must be set before opening any BizBundle UI

---

**This implementation enables seamless integration between Flutter UI and Tuya's native BizBundle UI components!** 🎉

