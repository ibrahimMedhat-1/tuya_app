import 'package:flutter/material.dart';
import 'package:tuya_app/src/core/utils/app_imports.dart';
import 'package:tuya_app/src/features/home/domain/entities/device.dart';

class DeviceCard extends StatelessWidget {
  final DeviceEntity device;
  final VoidCallback? onTap;
  final Function(bool)? onToggle;
  final bool isLoading;

  const DeviceCard({
    super.key,
    required this.device,
    this.onTap,
    this.onToggle,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: device.isOnline
                  ? [
                      Colors.blue.shade50,
                      Colors.blue.shade100,
                    ]
                  : [
                      Colors.grey.shade50,
                      Colors.grey.shade100,
                    ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Device Icon and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: device.isOnline ? Colors.blue.shade100 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getDeviceIcon(),
                      size: 24,
                      color: device.isOnline ? Colors.blue.shade600 : Colors.grey.shade600,
                    ),
                  ),
                  _buildStatusIndicator(),
                ],
              ),
              
              12.height,
              
              // Device Name
              Text(
                device.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const Spacer(),
              
              // Control Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    device.isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      color: device.isOnline ? Colors.green.shade600 : Colors.red.shade600,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  if (onToggle != null)
                    SizedBox(
                      height: 24,
                      child: Switch(
                        value: device.isOn,
                        onChanged: isLoading ? null : onToggle,
                        activeColor: Colors.blue.shade600,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: device.isOnline ? Colors.green : Colors.red,
        shape: BoxShape.circle,
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
}
