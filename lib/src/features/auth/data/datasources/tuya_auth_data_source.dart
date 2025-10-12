import 'package:tuya_app/src/core/error/failures.dart';
import 'package:tuya_app/src/core/utils/app_imports.dart';
 import 'package:tuya_app/src/core/utils/either.dart';

class TuyaAuthDataSource {
  User? _currentUser;

  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final result = await AppConstants.channel.invokeMethod('login', {
        'email': email,
        'password': password,
      });
      _currentUser = User.fromJson(result);
      return Right(_currentUser!);
    } on PlatformException catch (e) {
      return Left(_handlePlatformException(e));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  Future<Either<Failure, User?>> isLoggedIn() async {
    try {
      final result = await AppConstants.channel.invokeMethod('isLoggedIn');
      if (result != null) {
        _currentUser = User.fromJson(result);
        return Right(_currentUser);
      }
      return const Right(null);
    } on PlatformException catch (e) {
      return Left(_handlePlatformException(e));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  Future<Either<Failure, void>> logout() async {
    try {
      await AppConstants.channel.invokeMethod('logout');
      _currentUser = null;
      return const Right(null);
    } on PlatformException catch (e) {
      return Left(_handlePlatformException(e));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  Failure _handlePlatformException(PlatformException e) {
    return ServerFailure(e.message ?? 'An unknown platform error occurred.');
  }
}
