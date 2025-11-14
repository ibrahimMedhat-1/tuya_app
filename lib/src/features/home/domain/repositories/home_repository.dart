import 'package:tuya_app/src/core/error/failures.dart';
import 'package:tuya_app/src/core/utils/either.dart';

import '../entities/device.dart';
import '../entities/home.dart';
import '../entities/room.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<HomeEntity>>> getUserHomes();
  Future<Either<Failure, List<DeviceEntity>>> getHomeDevices(
    int homeId, {
    String? homeName,
  });
  Future<Either<Failure, List<RoomEntity>>> getHomeRooms(int homeId);
  Future<Either<Failure, List<DeviceEntity>>> getRoomDevices(
    int homeId,
    int roomId,
  );
  Future<Either<Failure, HomeEntity>> addHouse({
    required String name,
    String? geoName,
    double? lon,
    double? lat,
    List<String>? roomNames,
  });
  Future<Either<Failure, RoomEntity>> addRoom({
    required int homeId,
    required String name,
    String? iconUrl,
  });
  Future<Either<Failure, void>> controlDevice({
    required String deviceId,
    required Map<String, Object> dps,
  });
  Future<Either<Failure, void>> pairDevices();
  Future<Either<Failure, void>> addDeviceToRoom({
    required int homeId,
    required int roomId,
    required String deviceId,
  });
  Future<Either<Failure, void>> removeDeviceFromRoom({
    required int homeId,
    required int roomId,
    required String deviceId,
  });
  Future<Either<Failure, void>> updateRoomName({
    required int homeId,
    required int roomId,
    required String name,
  });
  Future<Either<Failure, void>> removeRoom({
    required int homeId,
    required int roomId,
  });
}
