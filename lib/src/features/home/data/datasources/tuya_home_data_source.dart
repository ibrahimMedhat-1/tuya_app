import 'package:flutter/services.dart';
import 'package:tuya_app/src/core/error/failures.dart';
import 'package:tuya_app/src/core/utils/constants.dart';
import 'package:tuya_app/src/core/utils/either.dart';

class TuyaHomeDataSource {
  Future<Either<Failure, List<Map<String, dynamic>>>> getUserHomes() async {
    try {
      final result = await AppConstants.channel.invokeMethod('getHomes');
      final List list = result as List;
      return Right(
        list.cast<Map>().map((e) => Map<String, dynamic>.from(e)).toList(),
      );
    } on PlatformException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to get homes'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<Map<String, dynamic>>>> getHomeDevices(
    int homeId, {
    String? homeName,
  }) async {
    try {
      final result = await AppConstants.channel.invokeMethod('getHomeDevices', {
        'homeId': homeId,
        'homeName': homeName,
      });
      final List list = result as List;
      return Right(
        list.cast<Map>().map((e) => Map<String, dynamic>.from(e)).toList(),
      );
    } on PlatformException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to get devices'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<Map<String, dynamic>>>> getHomeRooms(
    int homeId,
  ) async {
    try {
      final result = await AppConstants.channel.invokeMethod('getHomeRooms', {
        'homeId': homeId,
      });
      final List list = result as List;
      return Right(
        list.cast<Map>().map((e) => Map<String, dynamic>.from(e)).toList(),
      );
    } on PlatformException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to get rooms'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<Map<String, dynamic>>>> getRoomDevices(
    int homeId,
    int roomId,
  ) async {
    try {
      final result = await AppConstants.channel.invokeMethod('getRoomDevices', {
        'homeId': homeId,
        'roomId': roomId,
      });
      final List list = result as List;
      return Right(
        list.cast<Map>().map((e) => Map<String, dynamic>.from(e)).toList(),
      );
    } on PlatformException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to get room devices'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addHouse({
    required String name,
    String? geoName,
    double? lon,
    double? lat,
    List<String>? roomNames,
  }) async {
    try {
      final result = await AppConstants.channel.invokeMethod('addHouse', {
        'name': name,
        'geoName': geoName,
        'lon': lon,
        'lat': lat,
        'roomNames': roomNames,
      });
      return Right(Map<String, dynamic>.from(result as Map));
    } on PlatformException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to add house'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addRoom({
    required int homeId,
    required String name,
    String? iconUrl,
  }) async {
    try {
      final result = await AppConstants.channel.invokeMethod('addRoom', {
        'homeId': homeId,
        'name': name,
        'iconUrl': iconUrl,
      });
      return Right(Map<String, dynamic>.from(result as Map));
    } on PlatformException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to add room'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> controlDevice({
    required String deviceId,
    required Map<String, Object> dps,
  }) async {
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
      await AppConstants.channel.invokeMethod('pairDevices');
      return const Right(null);
    } on PlatformException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to pair devices'));
    } on MissingPluginException catch (e) {
      return Left(ServerFailure('Failed to pair devices: $e'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
