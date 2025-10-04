import 'package:flutter/material.dart';
import '../../tuya_sdk_plugin.dart';

/// Flutter Device Pairing Page
/// Provides a unified interface for device pairing across platforms
class DevicePairingPage extends StatefulWidget {
  const DevicePairingPage({Key? key}) : super(key: key);

  @override
  State<DevicePairingPage> createState() => _DevicePairingPageState();
}

class _DevicePairingPageState extends State<DevicePairingPage> {
  // State variables
  List<Map<String, dynamic>> _homes = [];
  List<Map<String, dynamic>> _devices = [];
  Map<String, dynamic>? _selectedHome;
  bool _isDiscovering = false;
  bool _isLoading = false;
  String _statusMessage = 'Select a home to start device discovery';

  // Controllers
  final TextEditingController _deviceNameController = TextEditingController();
  final TextEditingController _deviceIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadHomes();
  }

  @override
  void dispose() {
    _deviceNameController.dispose();
    _deviceIdController.dispose();
    super.dispose();
  }

  /// Load homes from Tuya SDK
  Future<void> _loadHomes() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Loading homes...';
    });

    try {
      final homes = await TuyaSdkPlugin.getHomes();
      setState(() {
        _homes = homes;
        _isLoading = false;
        if (homes.isNotEmpty) {
          _selectedHome = homes.first;
          _statusMessage = 'Select a home and tap "Start Discovery"';
        } else {
          _statusMessage = 'No homes found. Please create a home first.';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error loading homes: $e';
      });
    }
  }

  /// Load devices for selected home
  Future<void> _loadDevices() async {
    if (_selectedHome == null) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Loading devices...';
    });

    try {
      final devices = await TuyaSdkPlugin.getDevices(_selectedHome!['homeId']);
      setState(() {
        _devices = devices;
        _isLoading = false;
        _statusMessage = 'Found ${devices.length} device(s) in ${_selectedHome!['name']}';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error loading devices: $e';
      });
    }
  }

  /// Start device discovery
  Future<void> _startDiscovery() async {
    if (_selectedHome == null) {
      _showMessage('Please select a home first');
      return;
    }

    setState(() {
      _isDiscovering = true;
      _statusMessage = 'Discovering devices...';
    });

    try {
      final result = await TuyaSdkPlugin.startDeviceDiscovery(_selectedHome!['homeId']);
      setState(() {
        _statusMessage = result;
      });
      
      // Refresh devices after discovery
      await Future.delayed(const Duration(seconds: 2));
      await _loadDevices();
    } catch (e) {
      setState(() {
        _isDiscovering = false;
        _statusMessage = 'Discovery failed: $e';
      });
    }
  }

  /// Stop device discovery
  Future<void> _stopDiscovery() async {
    try {
      await TuyaSdkPlugin.stopDeviceDiscovery();
      setState(() {
        _isDiscovering = false;
        _statusMessage = 'Discovery stopped';
      });
    } catch (e) {
      _showMessage('Error stopping discovery: $e');
    }
  }

  /// Pair a device manually
  Future<void> _pairDevice() async {
    if (_selectedHome == null) {
      _showMessage('Please select a home first');
      return;
    }

    final deviceName = _deviceNameController.text.trim();
    final deviceId = _deviceIdController.text.trim();

    if (deviceName.isEmpty || deviceId.isEmpty) {
      _showMessage('Please enter both device name and ID');
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Pairing device...';
    });

    try {
      final result = await TuyaSdkPlugin.pairDevice(
        homeId: _selectedHome!['homeId'],
        deviceId: deviceId,
        deviceName: deviceName,
      );

      setState(() {
        _isLoading = false;
        _statusMessage = result;
      });

      _showMessage('Device paired successfully!');
      
      // Clear form
      _deviceNameController.clear();
      _deviceIdController.clear();
      
      // Refresh devices
      await _loadDevices();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Pairing failed: $e';
      });
      _showMessage('Pairing failed: $e');
    }
  }

  /// Show message to user
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Pairing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHomes,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status message
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else
                      Icon(
                        _isDiscovering ? Icons.radar : Icons.info,
                        size: 32,
                        color: _isDiscovering ? Colors.blue : Colors.grey,
                      ),
                    const SizedBox(height: 8),
                    Text(
                      _statusMessage,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Home selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Home',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<Map<String, dynamic>>(
                      value: _selectedHome,
                      isExpanded: true,
                      hint: const Text('Choose a home'),
                      items: _homes.map((home) {
                        return DropdownMenuItem<Map<String, dynamic>>(
                          value: home,
                          child: Text(home['name'] ?? 'Unknown Home'),
                        );
                      }).toList(),
                      onChanged: (home) {
                        setState(() {
                          _selectedHome = home;
                          _devices = [];
                        });
                        if (home != null) {
                          _loadDevices();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Discovery controls
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Device Discovery',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isDiscovering ? null : _startDiscovery,
                            icon: const Icon(Icons.radar),
                            label: const Text('Start Discovery'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isDiscovering ? _stopDiscovery : null,
                            icon: const Icon(Icons.stop),
                            label: const Text('Stop Discovery'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Manual device pairing
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Manual Device Pairing',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _deviceNameController,
                      decoration: const InputDecoration(
                        labelText: 'Device Name',
                        hintText: 'Enter device name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _deviceIdController,
                      decoration: const InputDecoration(
                        labelText: 'Device ID',
                        hintText: 'Enter device ID',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _pairDevice,
                        icon: const Icon(Icons.add),
                        label: const Text('Pair Device'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Device list
            if (_devices.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Devices in ${_selectedHome?['name'] ?? 'Selected Home'}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...(_devices.map((device) => ListTile(
                        leading: CircleAvatar(
                          backgroundColor: device['isOnline'] == true ? Colors.green : Colors.red,
                          child: Icon(
                            Icons.device_hub,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(device['name'] ?? 'Unknown Device'),
                        subtitle: Text(
                          'ID: ${device['devId']}\nStatus: ${device['isOnline'] == true ? 'Online' : 'Offline'}',
                        ),
                        trailing: Icon(
                          device['isOnline'] == true ? Icons.wifi : Icons.wifi_off,
                          color: device['isOnline'] == true ? Colors.green : Colors.red,
                        ),
                      ))),
                    ],
                  ),
                ),
              ),
            ],

            // Platform-specific activities
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Native Activities',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => TuyaSdkPlugin.openAddDeviceActivity(),
                            icon: const Icon(Icons.add_circle),
                            label: const Text('Open Native Pairing'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => TuyaSdkPlugin.openHomeActivity(),
                            icon: const Icon(Icons.home),
                            label: const Text('Open Home'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
