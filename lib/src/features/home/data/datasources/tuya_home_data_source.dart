import 'package:tuya_app/src/core/utils/app_imports.dart';

class TuyaHomeDataSource {
  Future<List<Map<String, dynamic>>> getUserHomes() async {
    try {
      final result = await AppConstants.channel.invokeMethod('getHomes');
       final List list = result as List;
      return list.cast<Map>().map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } on PlatformException catch (e) {
      throw Exception('getHomes failed: ${e.message}');
    }
  }

  Future<List<Map<String, dynamic>>> getHomeDevices(int homeId) async {
    try {
       final result = await AppConstants.channel.invokeMethod('getHomeDevices', {
        'homeId': homeId,
      });
       final List list = result as List;
      return list.cast<Map>().map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } on PlatformException catch (e) {
      throw Exception('getHomeDevices failed: ${e.message}');
    }
  }

  Future<void> controlDevice({required String deviceId, required Map<String,Object> dps}) async {
    try {
      print('controle dev : $deviceId $dps');
      await AppConstants.channel.invokeMethod('controlDevice', {
        'deviceId': deviceId,
        'dps': dps,
      });
    } on PlatformException catch (e) {
      throw Exception('controlDevice failed: ${e.message}');
    }
  }
}


