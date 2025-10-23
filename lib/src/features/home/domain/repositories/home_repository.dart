import 'package:tuya_app/src/core/error/failures.dart';
import 'package:tuya_app/src/core/utils/either.dart';

import '../entities/device.dart';
import '../entities/home.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<HomeEntity>>> getUserHomes();
  Future<Either<Failure, List<DeviceEntity>>> getHomeDevices(int homeId, {String? homeName});
  Future<Either<Failure, void>> controlDevice({
    required String deviceId,
    required Map<String, Object> dps,
  });
  Future<Either<Failure, void>> pairDevices();
}


