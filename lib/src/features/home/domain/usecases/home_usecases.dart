import 'package:tuya_app/src/core/error/failures.dart';
import 'package:tuya_app/src/core/utils/either.dart';

import '../entities/device.dart';
import '../entities/home.dart';
import '../entities/room.dart';
import '../repositories/home_repository.dart';

class GetUserHomesUseCase {
  final HomeRepository _repository;

  GetUserHomesUseCase(this._repository);

  Future<Either<Failure, List<HomeEntity>>> call() =>
      _repository.getUserHomes();
}

class GetHomeDevicesUseCase {
  final HomeRepository _repository;

  GetHomeDevicesUseCase(this._repository);

  Future<Either<Failure, List<DeviceEntity>>> call(
    int homeId, {
    String? homeName,
  }) => _repository.getHomeDevices(homeId, homeName: homeName);
}

class GetHomeRoomsUseCase {
  final HomeRepository _repository;

  GetHomeRoomsUseCase(this._repository);

  Future<Either<Failure, List<RoomEntity>>> call(int homeId) =>
      _repository.getHomeRooms(homeId);
}

class GetRoomDevicesUseCase {
  final HomeRepository _repository;

  GetRoomDevicesUseCase(this._repository);

  Future<Either<Failure, List<DeviceEntity>>> call(int homeId, int roomId) =>
      _repository.getRoomDevices(homeId, roomId);
}

class AddHouseUseCase {
  final HomeRepository _repository;

  AddHouseUseCase(this._repository);

  Future<Either<Failure, HomeEntity>> call({
    required String name,
    String? geoName,
    double? lon,
    double? lat,
    List<String>? roomNames,
  }) => _repository.addHouse(
    name: name,
    geoName: geoName,
    lon: lon,
    lat: lat,
    roomNames: roomNames,
  );
}

class AddRoomUseCase {
  final HomeRepository _repository;

  AddRoomUseCase(this._repository);

  Future<Either<Failure, RoomEntity>> call({
    required int homeId,
    required String name,
    String? iconUrl,
  }) => _repository.addRoom(homeId: homeId, name: name, iconUrl: iconUrl);
}

class ControlDeviceUseCase {
  final HomeRepository _repository;

  ControlDeviceUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String deviceId,
    required Map<String, Object> dps,
  }) => _repository.controlDevice(deviceId: deviceId, dps: dps);
}

class PairDeviceUseCase {
  final HomeRepository _repository;

  PairDeviceUseCase(this._repository);

  Future<Either<Failure, void>> call() => _repository.pairDevices();
}
