import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tuya_app/src/core/helpers/spacing_extensions.dart';
import 'package:tuya_app/src/core/helpers/responsive_extensions.dart';
import 'package:tuya_app/src/features/home/domain/entities/device.dart';

class DeviceCard extends StatefulWidget {
  final DeviceEntity device;
  final bool isLoading;
  final int? homeId;
  final String? homeName;

  const DeviceCard({
    super.key,
    required this.device,
    this.isLoading = false,
    this.homeId,
    this.homeName,
  });

  @override
  State<DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  static const MethodChannel _channel = MethodChannel('com.zerotechiot.eg/tuya_sdk');
  bool _isOpeningPanel = false;
  DateTime? _lastTapTime;

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
              colors: widget.device.isOnline
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
                        color: widget.device.isOnline ? Colors.blue.shade200 : Colors.grey.shade300,
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
                widget.device.name,
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
                'ID: ${widget.device.deviceId}',
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
                  color: widget.device.isOnline ? Colors.blue.shade50 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(context.isMobile ? 8 : 6),
                ),
                child: Text(
                  widget.device.deviceType.toUpperCase(),
                  style: TextStyle(
                    color: widget.device.isOnline ? Colors.blue.shade700 : Colors.grey.shade600,
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
                    widget.device.isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      color: widget.device.isOnline ? Colors.green.shade600 : Colors.red.shade600,
                      fontWeight: FontWeight.w600,
                      fontSize: context.isMobile ? 12 : 10,
                    ),
                  ),
                  Icon(
                    widget.device.isOnline ? Icons.wifi : Icons.wifi_off,
                    size: context.isMobile ? 16 : 14,
                    color: widget.device.isOnline ? Colors.green.shade600 : Colors.red.shade600,
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
    if (widget.device.image.isNotEmpty && widget.device.image.startsWith('http')) {
      return Image.network(
        widget.device.image,
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
      color: widget.device.isOnline ? Colors.blue.shade50 : Colors.grey.shade100,
      child: Icon(
        _getDeviceIcon(),
        size: context.isMobile ? 28 : 24,
        color: widget.device.isOnline ? Colors.blue.shade600 : Colors.grey.shade600,
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
            color: widget.device.isOnline ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  IconData _getDeviceIcon() {
    switch (widget.device.deviceType) {
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
      // DEBOUNCING: Prevent multiple rapid taps
      final now = DateTime.now();
      if (_lastTapTime != null && now.difference(_lastTapTime!).inSeconds < 2) {
        print('⚠️  [Flutter] Ignoring rapid tap - please wait for panel to load');
        print('   Time since last tap: ${now.difference(_lastTapTime!).inMilliseconds}ms');
        return;
      }
      
      // Prevent tapping while panel is already opening
      if (_isOpeningPanel) {
        print('⚠️  [Flutter] Panel is already opening - please wait...');
        return;
      }
      
      _lastTapTime = now;
      
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('🔵 [Flutter] Device card TAPPED!');
      print('   Device ID: ${widget.device.deviceId}');
      print('   Device Name: ${widget.device.name}');
      print('   Home ID: ${widget.homeId}');
      print('   Home Name: ${widget.homeName ?? 'Home'}');
      print('   Channel: ${_channel.name}');
      print('═══════════════════════════════════════════════════════════');
      print('');
      _openDeviceControlPanel();
  }

  Future<void> _openDeviceControlPanel() async {
    // Set loading state
    setState(() {
      _isOpeningPanel = true;
    });
    
    try {
      print('🚀 [Flutter] Calling platform method: openDeviceControlPanel');
      print('   Arguments:');
      print('     - deviceId: ${widget.device.deviceId}');
      print('     - homeId: ${widget.homeId}');
      print('     - homeName: ${widget.homeName ?? 'Home'}');
      print('');
      print('⏳ [Flutter] Please wait - panel resources are downloading...');
      print('   This may take 10-30 seconds on first load');
      print('');
      
      final result = await _channel.invokeMethod('openDeviceControlPanel', {
        'deviceId': widget.device.deviceId,
        'homeId': widget.homeId,
        'homeName': widget.homeName ?? 'Home',
      });
      
      print('✅ [Flutter] Platform method call completed successfully!');
      print('   Result: $result');
      
      // Reset loading state after a delay (panel Activity takes over)
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted) {
        setState(() {
          _isOpeningPanel = false;
        });
      }
    } on PlatformException catch (e) {
      if (mounted) {
        setState(() {
          _isOpeningPanel = false;
        });
      }
      
      print('');
      print('❌❌❌ [Flutter] PlatformException ❌❌❌');
      print("   Message: '${e.message}'");
      print("   Code: ${e.code}");
      print("   Details: ${e.details}");
      debugPrint("   Stack trace: ${e.stacktrace}");
      print('❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌');
      print('');
      
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open device panel: ${e.message}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } on MissingPluginException catch (e) {
      if (mounted) {
        setState(() {
          _isOpeningPanel = false;
        });
      }
      
      print('');
      print('❌❌❌ [Flutter] MissingPluginException ❌❌❌');
      print('   MethodChannel handler NOT registered!');
      print('   Exception: $e');
      print('❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌');
      print('');
    } catch (e) {
      if (mounted) {
        setState(() {
          _isOpeningPanel = false;
        });
      }
      
      print('');
      print('❌❌❌ [Flutter] Unexpected Error ❌❌❌');
      print('   Error: $e');
      print('   Type: ${e.runtimeType}');
      print('❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌');
      print('');
    }
  }
}

