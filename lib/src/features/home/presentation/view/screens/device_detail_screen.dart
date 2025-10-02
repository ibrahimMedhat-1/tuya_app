import 'package:flutter/material.dart';
import 'package:tuya_app/src/core/utils/app_imports.dart';
import 'package:tuya_app/src/features/home/domain/entities/device.dart';
import '../../../presentation/manager/home_cubit.dart';

class DeviceDetailScreen extends StatelessWidget {
  final DeviceEntity device;

  const DeviceDetailScreen({
    super.key,
    required this.device,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<HomeCubit>(),
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text(device.name),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () => _showDeviceSettings(context),
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                // Device Header
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Device Icon
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: device.isOnline ? Colors.blue.shade100 : Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getDeviceIcon(),
                            size: 48,
                            color: device.isOnline ? Colors.blue.shade600 : Colors.grey.shade600,
                          ),
                        ),
                        
                        16.height,
                        
                        // Device Name and Status
                        Text(
                          device.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        8.height,
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: device.isOnline ? Colors.green : Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            8.width,
                            Text(
                              device.isOnline ? 'Online' : 'Offline',
                              style: TextStyle(
                                color: device.isOnline ? Colors.green.shade600 : Colors.red.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Device Controls
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Controls',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        16.height,
                        
                        // Power Control
                        _buildPowerControl(context),
                        
                        // Device-specific controls
                        if (device.detectedType == 'light') ...[
                          16.height,
                          _buildLightControls(context),
                        ] else if (device.detectedType == 'fan') ...[
                          16.height,
                          _buildFanControls(context),
                        ] else if (device.detectedType == 'thermostat') ...[
                          16.height,
                          _buildThermostatControls(context),
                        ],
                      ],
                    ),
                  ),
                ),
                
                // Device Information
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Device Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        12.height,
                        _buildInfoRow('Device ID', device.deviceId),
                        _buildInfoRow('Type', device.detectedType.toUpperCase()),
                        _buildInfoRow('Status', device.isOnline ? 'Online' : 'Offline'),
                        if (device.currentState.isNotEmpty) ...[
                          8.height,
                          const Divider(),
                          8.height,
                          const Text(
                            'Current State',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          8.height,
                          ...device.currentState.entries.map((entry) => 
                            _buildInfoRow(entry.key, entry.value.toString())
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                
                // Add some bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPowerControl(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Power',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Switch(
            value: device.isOn,
            onChanged: (value) {
              context.read<HomeCubit>().toggleDevice(device.deviceId, value);
            },
            activeColor: Colors.blue.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildLightControls(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Light Controls',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          16.height,
          
          // Brightness Control
          Row(
            children: [
              const Icon(Icons.brightness_6, size: 20),
              12.width,
              const Text('Brightness'),
              const Spacer(),
              Text('${device.brightness}%'),
            ],
          ),
          8.height,
          Slider(
            value: device.brightness.toDouble(),
            min: 0,
            max: 100,
            divisions: 20,
            onChanged: (value) {
              context.read<HomeCubit>().setBrightness(device.deviceId, value.round());
            },
            activeColor: Colors.blue.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildFanControls(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fan Controls',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          16.height,
          
          // Speed Control
          Row(
            children: [
              const Icon(Icons.speed, size: 20),
              12.width,
              const Text('Speed'),
              const Spacer(),
              Text('${device.brightness}%'),
            ],
          ),
          8.height,
          Slider(
            value: device.brightness.toDouble(),
            min: 0,
            max: 100,
            divisions: 10,
            onChanged: (value) {
              context.read<HomeCubit>().setBrightness(device.deviceId, value.round());
            },
            activeColor: Colors.blue.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildThermostatControls(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Temperature Control',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          16.height,
          
          // Temperature Control
          Row(
            children: [
              const Icon(Icons.thermostat, size: 20),
              12.width,
              const Text('Temperature'),
              const Spacer(),
              Text('${device.temperature}°C'),
            ],
          ),
          8.height,
          Slider(
            value: device.temperature.toDouble(),
            min: 16,
            max: 30,
            divisions: 14,
            onChanged: (value) {
              context.read<HomeCubit>().setTemperature(device.deviceId, value.round());
            },
            activeColor: Colors.blue.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDeviceIcon() {
    switch (device.detectedType) {
      case 'light':
        return Icons.lightbulb_outline;
      case 'fan':
        return Icons.air;
      case 'plug':
        return Icons.power;
      case 'camera':
        return Icons.videocam_outlined;
      case 'lock':
        return Icons.lock_outline;
      case 'sensor':
        return Icons.sensors;
      case 'switch':
        return Icons.toggle_on_outlined;
      case 'thermostat':
        return Icons.thermostat;
      case 'speaker':
        return Icons.speaker;
      default:
        return Icons.device_hub;
    }
  }

  void _showDeviceSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${device.name} Settings'),
        content: const Text('Device settings and configuration options will be available here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
