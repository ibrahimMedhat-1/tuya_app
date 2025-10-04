import 'package:get_it/get_it.dart';
import 'package:smart_home_tuya/application/blocs/auth/auth_bloc.dart';
import 'package:smart_home_tuya/application/usecases/login_usecase.dart';
import 'package:smart_home_tuya/application/usecases/register_usecase.dart';
import 'package:smart_home_tuya/data/datasources/tuya_auth_datasource.dart';
import 'package:smart_home_tuya/data/repositories/auth_repository_impl.dart';
import 'package:smart_home_tuya/domain/repositories/auth_repository.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // Data sources
  sl.registerLazySingleton(() => TuyaAuthDataSource());
  
  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );
  
  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  
  // BLoCs
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      authRepository: sl(),
    ),
  );
} 