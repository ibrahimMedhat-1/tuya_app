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

  const DeviceCard({super.key, required this.device, this.isLoading = false, this.homeId, this.homeName});

  @override
  State<DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  static const MethodChannel _channel = MethodChannel('com.zerotechiot.eg/tuya_sdk');
  bool _isOpeningPanel = false;
  DateTime? _lastTapTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(50), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleCardTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(context.isMobile ? 16 : 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row with Icon and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Device Icon
                    Container(
                      width: context.isMobile ? 48 : 44,
                      height: context.isMobile ? 48 : 44,
                      decoration: BoxDecoration(
                        color: widget.device.isOnline ? Colors.green.withAlpha(10) : Colors.grey.withAlpha(10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.network(widget.device.image),
                    ),
                    // Status Indicator
                    Container(
                      width: context.isMobile ? 8 : 6,
                      height: context.isMobile ? 8 : 6,
                      decoration: BoxDecoration(
                        color: widget.device.isOnline ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),

                16.height,

                // Device Name
                Text(
                  widget.device.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: context.isMobile ? 16 : 15,
                    color: Colors.grey.shade800,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                8.height,

                // Device Type Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: context.isMobile ? 8 : 6, vertical: context.isMobile ? 4 : 3),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    widget.device.deviceType.toUpperCase(),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: context.isMobile ? 10 : 9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const Spacer(),

                // Status Row
                Row(
                  children: [
                    Icon(
                      widget.device.isOnline ? Icons.wifi : Icons.wifi_off,
                      size: context.isMobile ? 14 : 12,
                      color: widget.device.isOnline ? Colors.green.shade600 : Colors.red.shade600,
                    ),
                    4.width,
                    Text(
                      widget.device.isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        color: widget.device.isOnline ? Colors.green.shade600 : Colors.red.shade600,
                        fontWeight: FontWeight.w500,
                        fontSize: context.isMobile ? 12 : 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleCardTap() {
    // DEBOUNCING: Prevent multiple rapid taps
    final now = DateTime.now();
    if (_lastTapTime != null && now.difference(_lastTapTime!).inSeconds < 2) {
      return;
    }

    // Prevent tapping while panel is already opening
    if (_isOpeningPanel) {
      return;
    }

    _lastTapTime = now;

    _openDeviceControlPanel();
  }

  Future<void> _openDeviceControlPanel() async {
    // Set loading state
    setState(() {
      _isOpeningPanel = true;
    });

    try {
      await _channel.invokeMethod('openDeviceControlPanel', {
        'deviceId': widget.device.deviceId,
        'homeId': widget.homeId,
        'homeName': widget.homeName ?? 'Home',
      });

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
    } on MissingPluginException catch (_) {
      if (mounted) {
        setState(() {
          _isOpeningPanel = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isOpeningPanel = false;
        });
      }
    }
  }
}
