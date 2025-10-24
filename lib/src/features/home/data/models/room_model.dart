import 'package:tuya_app/src/features/home/domain/entities/room.dart';

class RoomModel extends RoomEntity {
  const RoomModel({
    required super.roomId,
    required super.name,
    required super.deviceCount,
    super.icon,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      roomId: json['roomId'] as int,
      name: json['name'] as String,
      deviceCount: json['deviceCount'] as int,
      icon: json['icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'name': name,
      'deviceCount': deviceCount,
      'icon': icon,
    };
  }

  RoomEntity toEntity() {
    return RoomEntity(
      roomId: roomId,
      name: name,
      deviceCount: deviceCount,
      icon: icon,
    );
  }
}
