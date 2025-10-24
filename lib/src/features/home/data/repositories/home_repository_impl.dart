import 'package:tuya_app/src/core/error/failures.dart';
import 'package:tuya_app/src/core/utils/either.dart';
import 'package:tuya_app/src/features/home/domain/entities/device.dart';
import 'package:tuya_app/src/features/home/domain/entities/home.dart';
import 'package:tuya_app/src/features/home/domain/entities/room.dart';

import '../../domain/repositories/home_repository.dart';
import '../datasources/tuya_home_data_source.dart';
import '../models/device_model.dart';
import '../models/home_model.dart';
import '../models/room_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final TuyaHomeDataSource _dataSource;
  HomeRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<HomeEntity>>> getUserHomes() async {
    final result = await _dataSource.getUserHomes();
    return result.fold(
      (failure) => Left(failure),
      (list) =>
          Right(list.map((e) => HomeModel.fromJson(e).toEntity()).toList()),
    );
  }

  @override
  Future<Either<Failure, List<DeviceEntity>>> getHomeDevices(
    int homeId, {
    String? homeName,
  }) async {
    final result = await _dataSource.getHomeDevices(homeId, homeName: homeName);
    return result.fold(
      (failure) => Left(failure),
      (list) =>
          Right(list.map((e) => DeviceModel.fromJson(e).toEntity()).toList()),
    );
  }

  @override
  Future<Either<Failure, List<RoomEntity>>> getHomeRooms(int homeId) async {
    final result = await _dataSource.getHomeRooms(homeId);
    return result.fold(
      (failure) => Left(failure),
      (list) =>
          Right(list.map((e) => RoomModel.fromJson(e).toEntity()).toList()),
    );
  }

  @override
  Future<Either<Failure, List<DeviceEntity>>> getRoomDevices(
    int homeId,
    int roomId,
  ) async {
    final result = await _dataSource.getRoomDevices(homeId, roomId);
    return result.fold(
      (failure) => Left(failure),
      (list) =>
          Right(list.map((e) => DeviceModel.fromJson(e).toEntity()).toList()),
    );
  }

  @override
  Future<Either<Failure, HomeEntity>> addHouse({
    required String name,
    String? geoName,
    double? lon,
    double? lat,
    List<String>? roomNames,
  }) async {
    final result = await _dataSource.addHouse(
      name: name,
      geoName: geoName,
      lon: lon,
      lat: lat,
    );
    return result.fold(
      (failure) => Left(failure),
      (data) => Right(HomeModel.fromJson(data).toEntity()),
    );
  }

  @override
  Future<Either<Failure, RoomEntity>> addRoom({
    required int homeId,
    required String name,
    String? iconUrl,
  }) async {
    final result = await _dataSource.addRoom(
      homeId: homeId,
      name: name,
      iconUrl: iconUrl,
    );
    return result.fold(
      (failure) => Left(failure),
      (data) => Right(RoomModel.fromJson(data).toEntity()),
    );
  }

  @override
  Future<Either<Failure, void>> controlDevice({
    required String deviceId,
    required Map<String, Object> dps,
  }) async {
    return await _dataSource.controlDevice(deviceId: deviceId, dps: dps);
  }

  @override
  Future<Either<Failure, void>> pairDevices() async {
    return await _dataSource.pairDevices();
  }
}
