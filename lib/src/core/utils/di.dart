import 'package:get_it/get_it.dart';
import 'package:tuya_app/src/features/auth/presentation/manager/cubit/auth_cubit.dart';
import 'package:tuya_app/src/features/device_pairing/data/datasources/tuya_device_pairing_data_source.dart';
import 'package:tuya_app/src/features/device_pairing/data/repositories/device_pairing_repository_impl.dart';
import 'package:tuya_app/src/features/device_pairing/domain/repositories/device_pairing_repository.dart';
import 'package:tuya_app/src/features/device_pairing/presentation/manager/cubit/device_pairing_cubit.dart';

import 'app_imports.dart';

final GetIt sl = GetIt.instance; // sl often stands for Service Locator

Future<void> getItInit() async {
  // Auth dependencies
  sl.registerLazySingleton<TuyaAuthDataSource>(() => TuyaAuthDataSource());
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<TuyaAuthDataSource>()),
  );
  sl.registerLazySingleton<AuthUseCase>(
    () => AuthUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<AuthCubit>(() => AuthCubit());

  // Device pairing dependencies
  sl.registerLazySingleton<TuyaDevicePairingDataSource>(
    () => TuyaDevicePairingDataSource(),
  );
  sl.registerLazySingleton<DevicePairingRepository>(
    () => DevicePairingRepositoryImpl(sl<TuyaDevicePairingDataSource>()),
  );
  sl.registerLazySingleton<DevicePairingCubit>(
    () => DevicePairingCubit(sl<DevicePairingRepository>()),
  );
}
