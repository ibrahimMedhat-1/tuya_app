import 'package:tuya_app/src/core/error/failures.dart';
import 'package:tuya_app/src/core/utils/either.dart';

import '../entities/device.dart';
import '../entities/home.dart';
import '../repositories/home_repository.dart';

class GetUserHomesUseCase {
  final HomeRepository _repository;

  GetUserHomesUseCase(this._repository);

  Future<Either<Failure, List<HomeEntity>>> call() => _repository.getUserHomes();
}

class GetHomeDevicesUseCase {
  final HomeRepository _repository;

  GetHomeDevicesUseCase(this._repository);

  Future<Either<Failure, List<DeviceEntity>>> call(int homeId) =>
      _repository.getHomeDevices(homeId);
}

class ControlDeviceUseCase {
  final HomeRepository _repository;

  ControlDeviceUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String deviceId,
    required Map<String, Object> dps,
  }) =>
      _repository.controlDevice(deviceId: deviceId, dps: dps);
}

class PairDeviceUseCase {
  final HomeRepository _repository;

  PairDeviceUseCase(this._repository);

  Future<Either<Failure, void>> call() => _repository.pairDevices();
}

