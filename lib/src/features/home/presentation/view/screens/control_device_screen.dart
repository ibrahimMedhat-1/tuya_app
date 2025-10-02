import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for PlatformException and MethodChannel

// Placeholder Device Entity - In a real app, this would come from your domain layer
class Device {
  final String id;
  final String name;
  final IconData icon;

  Device({required this.id, required this.name, this.icon = Icons.device_unknown});
}

class ControlDeviceScreen extends StatelessWidget {
  ControlDeviceScreen({super.key});

  // Define the method channel
  static const platformChannel = MethodChannel('com.zerotechiot.eg/tuya_sdk');

  // Placeholder list of devices
  final List<Device> devices = [
    Device(id: '1', name: 'Living Room Light', icon: Icons.lightbulb_outline),
    Device(id: '2', name: 'Bedroom Fan', icon: Icons.air_outlined),
    Device(id: '3', name: 'Smart Plug Mini', icon: Icons.power_settings_new),
    Device(id: '4', name: 'Kitchen Camera', icon: Icons.videocam_outlined),
  ];

  Future<void> _goToDevicePanel(BuildContext context, String deviceId, String deviceName) async {
    try {
      await platformChannel.invokeMethod('goToDevicePanel', {'deviceId': deviceId});
      // Optionally, show a success message or log
      print('Successfully requested to open panel for $deviceName');
    } on PlatformException catch (e) {
      // Handle error, e.g., show a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open device panel for $deviceName: ${e.message}')),
      );
      print('Error opening device panel for $deviceName: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control Device'),
      ),
      body: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final device = devices[index];
          return ListTile(
            leading: Icon(device.icon, size: 40.0),
            title: Text(device.name),
            subtitle: Text('ID: ${device.id}'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _goToDevicePanel(context, device.id, device.name);
            },
          );
        },
      ),
    );
  }
}
