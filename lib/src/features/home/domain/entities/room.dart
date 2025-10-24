class RoomEntity {
  final int roomId;
  final String name;
  final int deviceCount;
  final String? icon;

  const RoomEntity({
    required this.roomId,
    required this.name,
    required this.deviceCount,
    this.icon,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoomEntity &&
          runtimeType == other.runtimeType &&
          roomId == other.roomId &&
          name == other.name &&
          deviceCount == other.deviceCount &&
          icon == other.icon;

  @override
  int get hashCode =>
      roomId.hashCode ^ name.hashCode ^ deviceCount.hashCode ^ icon.hashCode;

  @override
  String toString() {
    return 'RoomEntity{roomId: $roomId, name: $name, deviceCount: $deviceCount, icon: $icon}';
  }
}
