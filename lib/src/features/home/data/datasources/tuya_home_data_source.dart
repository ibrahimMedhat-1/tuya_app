import 'package:flutter/services.dart';
import 'package:tuya_app/src/core/error/failures.dart';
import 'package:tuya_app/src/core/utils/constants.dart';
import 'package:tuya_app/src/core/utils/either.dart';

class TuyaHomeDataSource {
  Future<Either<Failure, List<Map<String, dynamic>>>> getUserHomes() async {
    try {
      final result = await AppConstants.channel.invokeMethod('getHomes');
      final List list = result as List;
      return Right(list.cast<Map>().map((e) => Map<String, dynamic>.from(e)).toList());
    } on PlatformException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to get homes'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<Map<String, dynamic>>>> getHomeDevices(
      int homeId) async {
    try {
      final result = await AppConstants.channel.invokeMethod('getHomeDevices', {
        'homeId': homeId,
      });
      final List list = result as List;
      return Right(list.cast<Map>().map((e) => Map<String, dynamic>.from(e)).toList());
    } on PlatformException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to get devices'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> controlDevice(
      {required String deviceId, required Map<String, Object> dps}) async {
    try {
      await AppConstants.channel.invokeMethod('controlDevice', {
        'deviceId': deviceId,
        'dps': dps,
      });
      return const Right(null);
    } on PlatformException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to control device'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> pairDevices() async {
    try {
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('🔵 [Flutter] "Add Device" button TAPPED!');
      print('   Channel: ${AppConstants.channel.name}');
      print('   Method: pairDevices');
      print('═══════════════════════════════════════════════════════════');
      print('');
      
      print('🚀 [Flutter] Calling iOS method: pairDevices');
      await AppConstants.channel.invokeMethod('pairDevices');
      
      print('✅ [Flutter] iOS method call completed successfully!');
      return const Right(null);
    } on PlatformException catch (e) {
      print('');
      print('❌❌❌ [Flutter] PlatformException ❌❌❌');
      print("   Message: '${e.message}'");
      print("   Code: ${e.code}");
      print('❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌');
      print('');
      return Left(ServerFailure(e.message ?? 'Failed to pair devices'));
    } on MissingPluginException catch (e) {
      print('');
      print('❌❌❌ [Flutter] MissingPluginException ❌❌❌');
      print('   MethodChannel handler NOT registered on iOS!');
      print('   Exception: $e');
      print('❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌');
      print('');
      return Left(ServerFailure('Failed to pair devices'));
    } catch (e) {
      print('');
      print('❌❌❌ [Flutter] Unexpected Error ❌❌❌');
      print('   Error: $e');
      print('   Type: ${e.runtimeType}');
      print('❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌');
      print('');
      return Left(ServerFailure(e.toString()));
    }
  }
}


