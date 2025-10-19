import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tuya_app/src/core/helpers/spacing_extensions.dart';
import 'package:tuya_app/src/core/helpers/responsive_extensions.dart';
import 'package:tuya_app/src/features/home/domain/entities/device.dart';

class DeviceCard extends StatelessWidget {
  final DeviceEntity device;
  final bool isLoading;
  final int? homeId;
  final String? homeName;

  static const MethodChannel _channel = MethodChannel('com.zerotechiot.eg/tuya_sdk');

  const DeviceCard({
    super.key,
    required this.device,
    this.isLoading = false,
    this.homeId,
    this.homeName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: context.isMobile ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.isMobile ? 16 : 12),
      ),
      child: InkWell(
        onTap: _handleCardTap,
        borderRadius: BorderRadius.circular(context.isMobile ? 16 : 12),
        child: Container(
          padding: context.responsivePadding,
          constraints: BoxConstraints(
            minHeight: context.isMobile ? 180 : 160,
            maxHeight: context.isMobile ? 250 : 230,
          ),
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
              // Device Image and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Device Image
                  Container(
                    width: context.isMobile ? 60 : 50,
                    height: context.isMobile ? 60 : 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(context.isMobile ? 12 : 10),
                      border: Border.all(
                        color: device.isOnline ? Colors.blue.shade200 : Colors.grey.shade300,
                        width: context.isMobile ? 1.5 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(context.isMobile ? 12 : 10),
                      child: _buildDeviceImage(context),
                    ),
                  ),
                  _buildStatusIndicator(),
                ],
              ),

              12.height,

              // Device Name
              Text(
                device.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: context.isMobile ? 16 : 14,
                ),
                maxLines: context.isMobile ? 1 : 2,
                overflow: TextOverflow.ellipsis,
              ),

              (context.isMobile ? 8 : 6).height,

              // Device ID
              Text(
                'ID: ${device.deviceId}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: context.isMobile ? 12 : 10,
                  fontFamily: 'monospace',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              (context.isMobile ? 8 : 6).height,

              // Device Type
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.isMobile ? 8 : 6,
                  vertical: context.isMobile ? 4 : 3,
                ),
                decoration: BoxDecoration(
                  color: device.isOnline ? Colors.blue.shade50 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(context.isMobile ? 8 : 6),
                ),
                child: Text(
                  device.deviceType.toUpperCase(),
                  style: TextStyle(
                    color: device.isOnline ? Colors.blue.shade700 : Colors.grey.shade600,
                    fontSize: context.isMobile ? 10 : 8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const Spacer(),

              // Status Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    device.isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      color: device.isOnline ? Colors.green.shade600 : Colors.red.shade600,
                      fontWeight: FontWeight.w600,
                      fontSize: context.isMobile ? 12 : 10,
                    ),
                  ),
                  Icon(
                    device.isOnline ? Icons.wifi : Icons.wifi_off,
                    size: context.isMobile ? 16 : 14,
                    color: device.isOnline ? Colors.green.shade600 : Colors.red.shade600,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceImage(BuildContext context) {
    // If device has an image URL, try to load it
    if (device.image.isNotEmpty && device.image.startsWith('http')) {
      return Image.network(
        device.image,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackIcon(context);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey.shade100,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: context.isMobile ? 2 : 1.5,
              ),
            ),
          );
        },
      );
    }

    // Fallback to device type icon
    return _buildFallbackIcon(context);
  }

  Widget _buildFallbackIcon(BuildContext context) {
    return Container(
      color: device.isOnline ? Colors.blue.shade50 : Colors.grey.shade100,
      child: Icon(
        _getDeviceIcon(),
        size: context.isMobile ? 28 : 24,
        color: device.isOnline ? Colors.blue.shade600 : Colors.grey.shade600,
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = context.isMobile ? 8.0 : 6.0;
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: device.isOnline ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  IconData _getDeviceIcon() {
    switch (device.deviceType) {
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

  void _handleCardTap() {
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('🔵 [Flutter] Device card TAPPED!');
      print('   Device ID: ${device.deviceId}');
      print('   Device Name: ${device.name}');
      print('   Home ID: $homeId');
      print('   Home Name: ${homeName ?? 'Home'}');
      print('   Channel: ${_channel.name}');
      print('═══════════════════════════════════════════════════════════');
      print('');
      _openDeviceControlPanel();
  }

  Future<void> _openDeviceControlPanel() async {
    try {
      print('🚀 [Flutter] Calling iOS method: openDeviceControlPanel');
      print('   Arguments:');
      print('     - deviceId: ${device.deviceId}');
      print('     - homeId: $homeId');
      print('     - homeName: ${homeName ?? 'Home'}');
      
      final result = await _channel.invokeMethod('openDeviceControlPanel', {
        'deviceId': device.deviceId,
        'homeId': homeId,
        'homeName': homeName ?? 'Home',
      });
      
      print('✅ [Flutter] iOS method call completed successfully!');
      print('   Result from iOS: $result');
    } on PlatformException catch (e) {
      print('');
      print('❌❌❌ [Flutter] PlatformException ❌❌❌');
      print("   Message: '${e.message}'");
      print("   Code: ${e.code}");
      print("   Details: ${e.details}");
      debugPrint("   Stack trace: ${e.stacktrace}");
      print('❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌');
      print('');
    } on MissingPluginException catch (e) {
      print('');
      print('❌❌❌ [Flutter] MissingPluginException ❌❌❌');
      print('   MethodChannel handler NOT registered on iOS!');
      print('   This means iOS is not listening to this channel.');
      print('   Exception: $e');
      print('❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌');
      print('');
    } catch (e) {
      print('');
      print('❌❌❌ [Flutter] Unexpected Error ❌❌❌');
      print('   Error: $e');
      print('   Type: ${e.runtimeType}');
      print('❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌');
      print('');
    }
  }
}

