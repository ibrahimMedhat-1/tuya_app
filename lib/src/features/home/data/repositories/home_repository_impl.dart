import '../../domain/entities/device.dart';
import '../../domain/entities/home.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/tuya_home_data_source.dart';
import '../models/device_model.dart';
import '../models/home_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final TuyaHomeDataSource _dataSource;
  HomeRepositoryImpl(this._dataSource);

  @override
  Future<List<HomeEntity>> getUserHomes() async {
    final list = await _dataSource.getUserHomes();
    return list.map((e) => HomeModel.fromJson(e).toEntity()).toList();
  }

  @override
  Future<List<DeviceEntity>> getHomeDevices(int homeId) async {
    final list = await _dataSource.getHomeDevices(homeId);
    return list.map((e) => DeviceModel.fromJson(e).toEntity()).toList();
  }

  @override
  Future<void> controlDevice({required String deviceId, required Map<String,Object> dps}) async {
    await _dataSource.controlDevice(deviceId: deviceId, dps: dps);
  }

  @override
  Future pairDevices()async{
    await _dataSource.pairDevices();
  }
}


