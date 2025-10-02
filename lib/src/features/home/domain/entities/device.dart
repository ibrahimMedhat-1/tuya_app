class DeviceEntity {
  final String deviceId;
  final String name;
  final bool isOnline;
  final String image;
  final String deviceType;
  final Map<String, dynamic> capabilities;
  final Map<String, dynamic> currentState;

  const DeviceEntity({
    required this.deviceId,
    required this.name,
    required this.isOnline,
    required this.image,
    this.deviceType = 'unknown',
    this.capabilities = const {},
    this.currentState = const {},
  });

  DeviceEntity copyWith({
    String? deviceId,
    String? name,
    bool? isOnline,
    String? image,
    String? deviceType,
    Map<String, dynamic>? capabilities,
    Map<String, dynamic>? currentState,
  }) {
    return DeviceEntity(
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      isOnline: isOnline ?? this.isOnline,
      image: image ?? this.image,
      deviceType: deviceType ?? this.deviceType,
      capabilities: capabilities ?? this.capabilities,
      currentState: currentState ?? this.currentState,
    );
  }

  // Helper methods for common device states
  bool get isOn => currentState['1'] == true || currentState['switch'] == true;
  
  int get brightness => currentState['brightness'] ?? currentState['2'] ?? 0;
  
  int get temperature => currentState['temperature'] ?? currentState['3'] ?? 0;
  
  String get color => currentState['color'] ?? currentState['4'] ?? '#FFFFFF';
  
  // Device type detection
  String get detectedType {
    final name = this.name.toLowerCase();
    if (name.contains('light') || name.contains('lamp') || name.contains('bulb')) {
      return 'light';
    } else if (name.contains('fan') || name.contains('air')) {
      return 'fan';
    } else if (name.contains('plug') || name.contains('outlet') || name.contains('socket')) {
      return 'plug';
    } else if (name.contains('camera') || name.contains('cam')) {
      return 'camera';
    } else if (name.contains('door') || name.contains('lock')) {
      return 'lock';
    } else if (name.contains('sensor') || name.contains('motion')) {
      return 'sensor';
    } else if (name.contains('switch')) {
      return 'switch';
    } else if (name.contains('thermostat') || name.contains('temp')) {
      return 'thermostat';
    } else if (name.contains('speaker') || name.contains('sound')) {
      return 'speaker';
    } else {
      return 'unknown';
    }
  }
}


