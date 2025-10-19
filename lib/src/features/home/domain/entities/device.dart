import 'package:equatable/equatable.dart';

class DeviceEntity extends Equatable {
  final String deviceId;
  final String name;
  final bool isOnline;
  final String deviceType;
  final String image;
  final Map<String, dynamic> capabilities;
  final Map<String, dynamic> currentState;

  const DeviceEntity({
    required this.deviceId,
    required this.name,
    required this.isOnline,
    required this.deviceType,
    required this.image,
    this.capabilities = const {},
    this.currentState = const {},
  });

  @override
  List<Object?> get props => [deviceId, name, isOnline, deviceType, image, capabilities, currentState];
}
