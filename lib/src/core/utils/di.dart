import 'package:get_it/get_it.dart';
import 'package:tuya_app/src/features/home/data/datasources/tuya_home_data_source.dart';
import 'package:tuya_app/src/features/home/data/repositories/home_repository_impl.dart';
import 'package:tuya_app/src/features/home/domain/repositories/home_repository.dart';
import 'package:tuya_app/src/features/home/domain/usecases/home_usecases.dart';

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
  sl.registerFactory<AuthCubit>(() => AuthCubit(sl<AuthUseCase>()));

  // Home dependencies
  sl.registerLazySingleton<TuyaHomeDataSource>(() => TuyaHomeDataSource());
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(sl<TuyaHomeDataSource>()),
  );
  sl.registerLazySingleton<GetUserHomesUseCase>(
    () => GetUserHomesUseCase(sl<HomeRepository>()),
  );
  sl.registerLazySingleton<GetHomeDevicesUseCase>(
    () => GetHomeDevicesUseCase(sl<HomeRepository>()),
  );
  sl.registerLazySingleton<GetHomeRoomsUseCase>(
    () => GetHomeRoomsUseCase(sl<HomeRepository>()),
  );
  sl.registerLazySingleton<GetRoomDevicesUseCase>(
    () => GetRoomDevicesUseCase(sl<HomeRepository>()),
  );
  sl.registerLazySingleton<AddHouseUseCase>(
    () => AddHouseUseCase(sl<HomeRepository>()),
  );
  sl.registerLazySingleton<AddRoomUseCase>(
    () => AddRoomUseCase(sl<HomeRepository>()),
  );
  sl.registerLazySingleton<ControlDeviceUseCase>(
    () => ControlDeviceUseCase(sl<HomeRepository>()),
  );
  sl.registerLazySingleton<PairDeviceUseCase>(
    () => PairDeviceUseCase(sl<HomeRepository>()),
  );
  sl.registerLazySingleton<AddDeviceToRoomUseCase>(
    () => AddDeviceToRoomUseCase(sl<HomeRepository>()),
  );
  sl.registerLazySingleton<RemoveDeviceFromRoomUseCase>(
    () => RemoveDeviceFromRoomUseCase(sl<HomeRepository>()),
  );
  sl.registerLazySingleton<UpdateRoomNameUseCase>(
    () => UpdateRoomNameUseCase(sl<HomeRepository>()),
  );
  sl.registerLazySingleton<RemoveRoomUseCase>(
    () => RemoveRoomUseCase(sl<HomeRepository>()),
  );
  sl.registerFactory<HomeCubit>(
    () => HomeCubit(
      sl<GetUserHomesUseCase>(),
      sl<GetHomeDevicesUseCase>(),
      sl<GetHomeRoomsUseCase>(),
      sl<GetRoomDevicesUseCase>(),
      sl<AddHouseUseCase>(),
      sl<AddRoomUseCase>(),
      sl<ControlDeviceUseCase>(),
      sl<PairDeviceUseCase>(),
      sl<AddDeviceToRoomUseCase>(),
      sl<RemoveDeviceFromRoomUseCase>(),
      sl<UpdateRoomNameUseCase>(),
      sl<RemoveRoomUseCase>(),
    ),
  );
}
