import 'package:get_it/get_it.dart';
import 'package:tuya_app/src/features/auth/presentation/manager/cubit/auth_cubit.dart';

import 'app_imports.dart';

final GetIt sl = GetIt.instance; // sl often stands for Service Locator

Future<void> getItInit() async {
  sl.registerLazySingleton<TuyaAuthDataSource>(() => TuyaAuthDataSource());
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl<TuyaAuthDataSource>()));
  sl.registerLazySingleton<AuthUseCase>(() => AuthUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton<AuthCubit>(() => AuthCubit());
}
