import '../../domain/entities/device.dart';

class DeviceModel {
  final String deviceId;
  final String name;
  final String image;
  final bool isOnline;
  final String deviceType;
  final Map<String, dynamic> capabilities;
  final Map<String, dynamic> currentState;

  const DeviceModel({
    required this.deviceId,
    required this.name,
    required this.isOnline,
    required this.image,
    this.deviceType = 'unknown',
    this.capabilities = const {},
    this.currentState = const {},
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      deviceId: (json['deviceId'] ?? json['devId'] ?? json['id']).toString(),
      name: (json['name'] ?? json['deviceName'] ?? '') as String,
      isOnline: (json['isOnline'] ?? json['online'] ?? false) as bool,
      image: (json['image'] ?? json['iconUrl'] ?? '') as String,
      deviceType: (json['deviceType'] ?? json['category'] ?? 'unknown') as String,
      capabilities: Map<String, dynamic>.from(json['capabilities'] ?? {}),
      currentState: Map<String, dynamic>.from(json['currentState'] ?? json['dps'] ?? {}),
    );
  }

  DeviceEntity toEntity() => DeviceEntity(
    deviceId: deviceId,
    name: name,
    isOnline: isOnline,
    image: image,
    deviceType: deviceType,
    capabilities: capabilities,
    currentState: currentState,
  );
}


