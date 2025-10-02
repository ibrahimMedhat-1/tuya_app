import '../entities/home.dart';
import '../entities/device.dart';

abstract class HomeRepository {
  Future<List<HomeEntity>> getUserHomes();
  Future<List<DeviceEntity>> getHomeDevices(int homeId);
  Future<void> controlDevice({required String deviceId, required Map<String,Object> dps});
}


