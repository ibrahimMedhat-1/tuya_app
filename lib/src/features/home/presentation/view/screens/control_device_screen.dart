import 'package:flutter/material.dart';

// Placeholder Device Entity - In a real app, this would come from your domain layer
class Device {
  final String id;
  final String name;
  final IconData icon;

  Device({required this.id, required this.name, this.icon = Icons.device_unknown});
}

class ControlDeviceScreen extends StatelessWidget {
    ControlDeviceScreen({super.key});

  // Placeholder list of devices
  final List<Device> devices =   [
    Device(id: '1', name: 'Living Room Light', icon: Icons.lightbulb_outline),
    Device(id: '2', name: 'Bedroom Fan', icon: Icons.air_outlined),
    Device(id: '3', name: 'Smart Plug Mini', icon: Icons.power_settings_new),
    Device(id: '4', name: 'Kitchen Camera', icon: Icons.videocam_outlined),
  ];

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
              // TODO: Navigate to individual device control screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tapped on ${device.name}')),
              );
            },
          );
        },
      ),
    );
  }
}
