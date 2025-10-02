import '../entities/device.dart';
import '../entities/home.dart';
import '../repositories/home_repository.dart';

class GetUserHomesUseCase {
  final HomeRepository _repository;
  GetUserHomesUseCase(this._repository);
  Future<List<HomeEntity>> call() => _repository.getUserHomes();
}

class GetHomeDevicesUseCase {
  final HomeRepository _repository;
  GetHomeDevicesUseCase(this._repository);
  Future<List<DeviceEntity>> call(int homeId) => _repository.getHomeDevices(homeId);
}

class ControlDeviceUseCase {
  final HomeRepository _repository;
  ControlDeviceUseCase(this._repository);
  Future<void> call({required String deviceId, required Map<String,Object> dps}) =>
      _repository.controlDevice(deviceId: deviceId, dps: dps);
}


