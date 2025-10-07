import 'package:flutter/material.dart';
import 'package:tuya_app/src/core/utils/constants.dart';
import 'package:tuya_app/src/features/device_pairing/data/datasources/tuya_device_pairing_data_source.dart';

/// Device Control Screen
/// Displays device details and provides controls for data points (DPs)
class DeviceControlScreen extends StatefulWidget {
  final Map<String, dynamic> device;

  const DeviceControlScreen({super.key, required this.device});

  @override
  State<DeviceControlScreen> createState() => _DeviceControlScreenState();
}

class _DeviceControlScreenState extends State<DeviceControlScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  Map<String, dynamic> _deviceStatus = {};
  Map<String, dynamic> _deviceSpecs = {};
  late AnimationController _animationController;
  final TuyaDevicePairingDataSource _dataSource = TuyaDevicePairingDataSource();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animationController.forward();
    _loadDeviceStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadDeviceStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get device specifications to understand available controls
      final specs = await _dataSource.getDeviceSpecifications(
        widget.device['id'],
      );
      setState(() {
        _deviceSpecs = specs;
      });

      // Mock device status based on device category
      // In a real app, this would come from the device's current DPs
      final category =
          widget.device['category']?.toString().toLowerCase() ?? '';
      setState(() {
        _deviceStatus = _getMockDeviceStatus(category);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Failed to load device status: $e', Colors.red);
    }
  }

  Map<String, dynamic> _getMockDeviceStatus(String category) {
    switch (category) {
      case 'light':
      case 'dj':
        return {
          '1': true, // Power
          '2': 75, // Brightness
          '3': 3000, // Color temperature
          '4': '{"h":200,"s":100,"v":100}', // Color
          '5': 'white', // Mode
        };
      case 'switch':
      case 'kg':
        return {
          '1': true, // Switch 1
          '2': false, // Switch 2 (if available)
          '3': false, // Switch 3 (if available)
        };
      case 'socket':
      case 'cz':
        return {
          '1': true, // Power
          '2': 0, // Power consumption
        };
      case 'sensor':
      case 'pir':
        return {
          '1': false, // Motion detected
          '2': 25, // Temperature
          '3': 60, // Humidity
          '4': 85, // Battery level
        };
      case 'lock':
      case 'ms':
        return {
          '1': 'unlock', // Lock status
          '2': 80, // Battery level
          '3': false, // Door open
        };
      case 'camera':
      case 'sp':
        return {
          '1': true, // Power
          '2': true, // Recording
          '3': true, // Motion detection
          '4': false, // Night vision
        };
      case 'curtain':
      case 'cl':
        return {
          '1': 'open', // Control (open/stop/close)
          '2': 50, // Position (0-100%)
        };
      case 'fan':
      case 'fs':
        return {
          '1': true, // Power
          '2': 3, // Speed (1-6)
          '3': true, // Oscillation
          '4': 'normal', // Mode
        };
      default:
        return {
          '1': true, // Basic power control
        };
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _controlDevice(String dpId, dynamic value) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final result = await AppConstants.channel.invokeMethod('controlDevice', {
        'deviceId': widget.device['id'],
        'dpId': dpId,
        'dpValue': value,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Device controlled successfully',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Update local status
        setState(() {
          _deviceStatus[dpId] = value;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to control device: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = widget.device['isOnline'] == true;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device['name'] ?? 'Device Control'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDeviceStatus,
            tooltip: 'Refresh Status',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: FadeTransition(
          opacity: _animationController,
          child: _isLoading && _deviceStatus.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Device Info Card
                      _buildDeviceInfoCard(isOnline),

                      const SizedBox(height: 24),

                      // Online Status Warning
                      if (!isOnline) _buildOfflineWarning(),

                      if (!isOnline) const SizedBox(height: 24),

                      // Controls Section
                      _buildControlsSection(isOnline),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildDeviceInfoCard(bool isOnline) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Device Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isOnline ? Colors.blue.shade50 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _getDeviceIcon(widget.device['category'] as String?),
                color: isOnline ? Colors.blue.shade700 : Colors.grey.shade400,
                size: 40,
              ),
            ),

            const SizedBox(height: 16),

            // Device Name
            Text(
              widget.device['name'] ?? 'Unknown Device',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Status Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isOnline ? Colors.green : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: isOnline
                        ? Colors.green.shade700
                        : Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Device Info
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 12),

            _buildInfoRow('Device ID:', widget.device['id'] ?? 'N/A'),
            _buildInfoRow('Category:', widget.device['category'] ?? 'N/A'),
            _buildInfoRow('Product ID:', widget.device['type'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineWarning() {
    return Card(
      color: Colors.orange.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Device is offline. Please check the device power and network connection.',
                style: TextStyle(color: Colors.orange.shade900),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlsSection(bool isOnline) {
    final category = widget.device['category']?.toString().toLowerCase() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Controls',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 16),

        // Dynamic controls based on device category
        ..._buildDeviceSpecificControls(category, isOnline),

        const SizedBox(height: 16),

        // Additional Controls Card
        _buildAdvancedControlsCard(isOnline),
      ],
    );
  }

  List<Widget> _buildDeviceSpecificControls(String category, bool isOnline) {
    switch (category) {
      case 'light':
      case 'dj':
        return _buildLightControls(isOnline);
      case 'switch':
      case 'kg':
        return _buildSwitchControls(isOnline);
      case 'socket':
      case 'cz':
        return _buildSocketControls(isOnline);
      case 'sensor':
      case 'pir':
        return _buildSensorControls(isOnline);
      case 'lock':
      case 'ms':
        return _buildLockControls(isOnline);
      case 'camera':
      case 'sp':
        return _buildCameraControls(isOnline);
      case 'curtain':
      case 'cl':
        return _buildCurtainControls(isOnline);
      case 'fan':
      case 'fs':
        return _buildFanControls(isOnline);
      default:
        return _buildDefaultControls(isOnline);
    }
  }

  // ===== DEVICE-SPECIFIC CONTROL BUILDERS =====

  List<Widget> _buildLightControls(bool isOnline) {
    return [
      _buildSwitchControl(
        title: 'Power',
        subtitle: 'Turn light on or off',
        icon: Icons.lightbulb,
        dpId: '1',
        value: _deviceStatus['1'] ?? false,
        enabled: isOnline,
      ),
      const SizedBox(height: 16),
      if (_deviceStatus['1'] == true) ...[
        _buildSliderControl(
          title: 'Brightness',
          subtitle: 'Adjust light brightness',
          icon: Icons.brightness_6,
          dpId: '2',
          value: (_deviceStatus['2'] ?? 50).toDouble(),
          min: 0,
          max: 100,
          enabled: isOnline,
        ),
        const SizedBox(height: 16),
        _buildSliderControl(
          title: 'Color Temperature',
          subtitle: 'Warm to cool white',
          icon: Icons.wb_sunny,
          dpId: '3',
          value: (_deviceStatus['3'] ?? 3000).toDouble(),
          min: 2700,
          max: 6500,
          enabled: isOnline,
        ),
        const SizedBox(height: 16),
        _buildModeSelector(
          title: 'Light Mode',
          subtitle: 'Choose lighting mode',
          icon: Icons.palette,
          dpId: '5',
          value: _deviceStatus['5'] ?? 'white',
          options: ['white', 'color', 'scene', 'night'],
          enabled: isOnline,
        ),
      ],
    ];
  }

  List<Widget> _buildSwitchControls(bool isOnline) {
    return [
      _buildSwitchControl(
        title: 'Switch 1',
        subtitle: 'Main switch control',
        icon: Icons.power_settings_new,
        dpId: '1',
        value: _deviceStatus['1'] ?? false,
        enabled: isOnline,
      ),
      if (_deviceStatus.containsKey('2')) ...[
        const SizedBox(height: 16),
        _buildSwitchControl(
          title: 'Switch 2',
          subtitle: 'Secondary switch',
          icon: Icons.power_settings_new,
          dpId: '2',
          value: _deviceStatus['2'] ?? false,
          enabled: isOnline,
        ),
      ],
      if (_deviceStatus.containsKey('3')) ...[
        const SizedBox(height: 16),
        _buildSwitchControl(
          title: 'Switch 3',
          subtitle: 'Third switch',
          icon: Icons.power_settings_new,
          dpId: '3',
          value: _deviceStatus['3'] ?? false,
          enabled: isOnline,
        ),
      ],
    ];
  }

  List<Widget> _buildSocketControls(bool isOnline) {
    return [
      _buildSwitchControl(
        title: 'Power',
        subtitle: 'Turn socket on or off',
        icon: Icons.electrical_services,
        dpId: '1',
        value: _deviceStatus['1'] ?? false,
        enabled: isOnline,
      ),
      if (_deviceStatus.containsKey('2')) ...[
        const SizedBox(height: 16),
        _buildInfoCard(
          title: 'Power Consumption',
          subtitle: 'Current power usage',
          icon: Icons.electric_bolt,
          value: '${_deviceStatus['2']}W',
        ),
      ],
    ];
  }

  List<Widget> _buildSensorControls(bool isOnline) {
    return [
      _buildInfoCard(
        title: 'Motion Detection',
        subtitle: 'Current motion status',
        icon: Icons.directions_run,
        value: (_deviceStatus['1'] ?? false) ? 'Motion Detected' : 'No Motion',
        valueColor: (_deviceStatus['1'] ?? false) ? Colors.red : Colors.green,
      ),
      const SizedBox(height: 16),
      _buildInfoCard(
        title: 'Temperature',
        subtitle: 'Current temperature',
        icon: Icons.thermostat,
        value: '${_deviceStatus['2'] ?? 0}°C',
      ),
      const SizedBox(height: 16),
      _buildInfoCard(
        title: 'Humidity',
        subtitle: 'Current humidity level',
        icon: Icons.water_drop,
        value: '${_deviceStatus['3'] ?? 0}%',
      ),
      const SizedBox(height: 16),
      _buildBatteryIndicator(_deviceStatus['4'] ?? 0),
    ];
  }

  List<Widget> _buildLockControls(bool isOnline) {
    return [
      _buildLockStatusCard(),
      const SizedBox(height: 16),
      _buildLockActionButtons(),
      const SizedBox(height: 16),
      _buildBatteryIndicator(_deviceStatus['2'] ?? 0),
      if (_deviceStatus.containsKey('3')) ...[
        const SizedBox(height: 16),
        _buildInfoCard(
          title: 'Door Status',
          subtitle: 'Current door position',
          icon: Icons.door_front_door,
          value: (_deviceStatus['3'] ?? false) ? 'Open' : 'Closed',
          valueColor: (_deviceStatus['3'] ?? false) ? Colors.red : Colors.green,
        ),
      ],
    ];
  }

  List<Widget> _buildCameraControls(bool isOnline) {
    return [
      _buildSwitchControl(
        title: 'Power',
        subtitle: 'Turn camera on or off',
        icon: Icons.videocam,
        dpId: '1',
        value: _deviceStatus['1'] ?? false,
        enabled: isOnline,
      ),
      const SizedBox(height: 16),
      _buildSwitchControl(
        title: 'Recording',
        subtitle: 'Start or stop recording',
        icon: Icons.fiber_manual_record,
        dpId: '2',
        value: _deviceStatus['2'] ?? false,
        enabled: isOnline && (_deviceStatus['1'] ?? false),
      ),
      const SizedBox(height: 16),
      _buildSwitchControl(
        title: 'Motion Detection',
        subtitle: 'Enable motion alerts',
        icon: Icons.motion_photos_on,
        dpId: '3',
        value: _deviceStatus['3'] ?? false,
        enabled: isOnline && (_deviceStatus['1'] ?? false),
      ),
      const SizedBox(height: 16),
      _buildSwitchControl(
        title: 'Night Vision',
        subtitle: 'Enable night vision mode',
        icon: Icons.nightlight_round,
        dpId: '4',
        value: _deviceStatus['4'] ?? false,
        enabled: isOnline && (_deviceStatus['1'] ?? false),
      ),
    ];
  }

  List<Widget> _buildCurtainControls(bool isOnline) {
    return [
      _buildCurtainVisualization(),
      const SizedBox(height: 16),
      _buildSliderControl(
        title: 'Position',
        subtitle: 'Curtain position (0-100%)',
        icon: Icons.vertical_align_center,
        dpId: '2',
        value: (_deviceStatus['2'] ?? 50).toDouble(),
        min: 0,
        max: 100,
        enabled: isOnline,
      ),
      const SizedBox(height: 16),
      _buildCurtainActionButtons(isOnline),
    ];
  }

  List<Widget> _buildFanControls(bool isOnline) {
    return [
      _buildSwitchControl(
        title: 'Power',
        subtitle: 'Turn fan on or off',
        icon: Icons.air,
        dpId: '1',
        value: _deviceStatus['1'] ?? false,
        enabled: isOnline,
      ),
      if (_deviceStatus['1'] == true) ...[
        const SizedBox(height: 16),
        _buildSliderControl(
          title: 'Speed',
          subtitle: 'Fan speed (1-6)',
          icon: Icons.speed,
          dpId: '2',
          value: (_deviceStatus['2'] ?? 3).toDouble(),
          min: 1,
          max: 6,
          enabled: isOnline,
        ),
        const SizedBox(height: 16),
        _buildSwitchControl(
          title: 'Oscillation',
          subtitle: 'Enable fan oscillation',
          icon: Icons.swap_horiz,
          dpId: '3',
          value: _deviceStatus['3'] ?? false,
          enabled: isOnline,
        ),
        const SizedBox(height: 16),
        _buildModeSelector(
          title: 'Fan Mode',
          subtitle: 'Choose fan mode',
          icon: Icons.mode_fan_off,
          dpId: '4',
          value: _deviceStatus['4'] ?? 'normal',
          options: ['normal', 'natural', 'sleep'],
          enabled: isOnline,
        ),
      ],
    ];
  }

  List<Widget> _buildDefaultControls(bool isOnline) {
    return [
      _buildSwitchControl(
        title: 'Power',
        subtitle: 'Turn device on or off',
        icon: Icons.power_settings_new,
        dpId: '1',
        value: _deviceStatus['1'] ?? false,
        enabled: isOnline,
      ),
    ];
  }

  Widget _buildSwitchControl({
    required String title,
    required String subtitle,
    required IconData icon,
    required String dpId,
    required bool value,
    required bool enabled,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: enabled ? Colors.blue.shade50 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: enabled ? Colors.blue.shade700 : Colors.grey.shade400,
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Switch(
          value: value,
          onChanged: enabled
              ? (newValue) {
                  _controlDevice(dpId, newValue);
                }
              : null,
          activeColor: Colors.blue.shade700,
        ),
      ),
    );
  }

  Widget _buildSliderControl({
    required String title,
    required String subtitle,
    required IconData icon,
    required String dpId,
    required double value,
    required double min,
    required double max,
    required bool enabled,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: enabled ? Colors.blue.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: enabled
                        ? Colors.blue.shade700
                        : Colors.grey.shade400,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${value.toInt()}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: enabled
                        ? Colors.blue.shade700
                        : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: 100,
              label: '${value.toInt()}%',
              onChanged: enabled
                  ? (newValue) {
                      setState(() {
                        _deviceStatus[dpId] = newValue.toInt();
                      });
                    }
                  : null,
              onChangeEnd: enabled
                  ? (newValue) {
                      _controlDevice(dpId, newValue.toInt());
                    }
                  : null,
              activeColor: Colors.blue.shade700,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedControlsCard(bool isOnline) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Advanced Controls',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Scene Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildSceneButton(
                  'Schedule',
                  Icons.schedule,
                  Colors.purple,
                  isOnline,
                ),
                _buildSceneButton(
                  'Timer',
                  Icons.timer,
                  Colors.orange,
                  isOnline,
                ),
                _buildSceneButton(
                  'Statistics',
                  Icons.analytics,
                  Colors.green,
                  isOnline,
                ),
                _buildSceneButton(
                  'Settings',
                  Icons.tune,
                  Colors.blue,
                  isOnline,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSceneButton(
    String label,
    IconData icon,
    Color color,
    bool enabled,
  ) {
    return OutlinedButton.icon(
      onPressed: enabled
          ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$label - Coming Soon!'),
                  duration: const Duration(seconds: 1),
                ),
              );
            }
          : null,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: enabled ? color : Colors.grey,
        side: BorderSide(color: enabled ? color : Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // ===== HELPER WIDGET BUILDERS =====

  Widget _buildInfoCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    Color? valueColor,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue.shade700),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: valueColor ?? Colors.blue.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildBatteryIndicator(int batteryLevel) {
    Color batteryColor;
    if (batteryLevel > 50) {
      batteryColor = Colors.green;
    } else if (batteryLevel > 20) {
      batteryColor = Colors.orange;
    } else {
      batteryColor = Colors.red;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.battery_std, color: batteryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Battery Level',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('$batteryLevel% remaining'),
                ],
              ),
            ),
            LinearProgressIndicator(
              value: batteryLevel / 100,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(batteryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSelector({
    required String title,
    required String subtitle,
    required IconData icon,
    required String dpId,
    required String value,
    required List<String> options,
    required bool enabled,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: enabled ? Colors.blue.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: enabled
                        ? Colors.blue.shade700
                        : Colors.grey.shade400,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: options.map((option) {
                final isSelected = option == value;
                return FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: enabled
                      ? (selected) {
                          if (selected) {
                            _controlDevice(dpId, option);
                          }
                        }
                      : null,
                  selectedColor: Colors.blue.shade100,
                  checkmarkColor: Colors.blue.shade700,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockStatusCard() {
    final lockStatus = _deviceStatus['1'] ?? 'unlock';
    final isLocked = lockStatus == 'lock';

    return Card(
      elevation: 4,
      color: isLocked ? Colors.red.shade50 : Colors.green.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              isLocked ? Icons.lock : Icons.lock_open,
              size: 60,
              color: isLocked ? Colors.red.shade700 : Colors.green.shade700,
            ),
            const SizedBox(height: 12),
            Text(
              isLocked ? 'LOCKED' : 'UNLOCKED',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isLocked ? Colors.red.shade700 : Colors.green.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _controlDevice('1', 'lock'),
            icon: const Icon(Icons.lock),
            label: const Text('Lock'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _controlDevice('1', 'unlock'),
            icon: const Icon(Icons.lock_open),
            label: const Text('Unlock'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurtainVisualization() {
    final position = _deviceStatus['2'] ?? 50;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Curtain Position',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  // Curtain track
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 20,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  // Curtain
                  Positioned(
                    top: 20,
                    left: 0,
                    right: 0,
                    height: 80,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade300,
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(8),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${position.toInt()}%',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurtainActionButtons(bool isOnline) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isOnline ? () => _controlDevice('1', 'open') : null,
            icon: const Icon(Icons.keyboard_arrow_up),
            label: const Text('Open'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isOnline ? () => _controlDevice('1', 'stop') : null,
            icon: const Icon(Icons.stop),
            label: const Text('Stop'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isOnline ? () => _controlDevice('1', 'close') : null,
            icon: const Icon(Icons.keyboard_arrow_down),
            label: const Text('Close'),
          ),
        ),
      ],
    );
  }

  IconData _getDeviceIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'light':
      case 'dj':
        return Icons.lightbulb;
      case 'switch':
      case 'kg':
        return Icons.power_settings_new;
      case 'socket':
      case 'cz':
        return Icons.electrical_services;
      case 'curtain':
      case 'cl':
        return Icons.curtains;
      case 'fan':
      case 'fs':
        return Icons.air;
      case 'sensor':
      case 'pir':
        return Icons.sensors;
      case 'lock':
      case 'ms':
        return Icons.lock;
      case 'camera':
      case 'sp':
        return Icons.videocam;
      default:
        return Icons.devices;
    }
  }
}
