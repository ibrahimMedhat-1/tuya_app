import 'package:get_it/get_it.dart';
import 'package:tuya_app/src/features/auth/data/datasources/tuya_auth_data_source.dart';
import 'package:tuya_app/src/features/auth/data/repositories/auth_repository.dart';
import 'package:tuya_app/src/features/auth/data/repositories/tuya_impl.dart';
import 'package:tuya_app/src/features/auth/domain/usecases/auth_usecase.dart';
import 'package:tuya_app/src/features/auth/presentation/manager/cubit/auth_cubit.dart';
import 'package:tuya_app/src/features/home/data/datasources/tuya_home_data_source.dart';
import 'package:tuya_app/src/features/home/data/repositories/home_repository_impl.dart';
import 'package:tuya_app/src/features/home/domain/repositories/home_repository.dart';
import 'package:tuya_app/src/features/home/domain/usecases/home_usecases.dart';
import 'package:tuya_app/src/features/home/presentation/manager/home_cubit.dart';

final GetIt sl = GetIt.instance; // sl often stands for Service Locator

Future<void> getItInit() async {
  sl.registerLazySingleton<TuyaAuthDataSource>(() => TuyaAuthDataSource());
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl<TuyaAuthDataSource>()));
  sl.registerLazySingleton<AuthUseCase>(() => AuthUseCase(sl<AuthRepository>()));
  sl.registerFactory<AuthCubit>(() => AuthCubit(sl<AuthUseCase>()));

  // Home feature
  sl.registerLazySingleton<TuyaHomeDataSource>(() => TuyaHomeDataSource());
  sl.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(sl<TuyaHomeDataSource>()));
  sl.registerLazySingleton<GetUserHomesUseCase>(() => GetUserHomesUseCase(sl<HomeRepository>()));
  sl.registerLazySingleton<GetHomeDevicesUseCase>(() => GetHomeDevicesUseCase(sl<HomeRepository>()));
  sl.registerLazySingleton<ControlDeviceUseCase>(() => ControlDeviceUseCase(sl<HomeRepository>()));
  sl.registerLazySingleton<PairDeviceUseCase>(() => PairDeviceUseCase(sl<HomeRepository>()));

  // Presentation
  sl.registerFactory<HomeCubit>(() => HomeCubit(
        sl<GetUserHomesUseCase>(),
        sl<GetHomeDevicesUseCase>(),
        sl<ControlDeviceUseCase>(),
        sl<PairDeviceUseCase>(),
      ));
}
