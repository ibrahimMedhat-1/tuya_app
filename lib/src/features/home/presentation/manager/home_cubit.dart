import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tuya_app/src/features/home/domain/entities/device.dart';
import 'package:tuya_app/src/features/home/domain/entities/home.dart';
import 'package:tuya_app/src/features/home/domain/usecases/home_usecases.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetUserHomesUseCase _getUserHomes;
  final GetHomeDevicesUseCase _getHomeDevices;
  final ControlDeviceUseCase _controlDeviceUseCase;
  final PairDeviceUseCase _pairDeviceUseCase;

  HomeCubit(
    this._getUserHomes,
    this._getHomeDevices,
    this._controlDeviceUseCase,
    this._pairDeviceUseCase,
  ) : super(HomeState.initial());

  Future<void> loadHomes() async {
    emit(state.copyWith(status: HomeStatus.loading, errorMessage: null));
    final result = await _getUserHomes();
    result.fold(
      (failure) => emit(state.copyWith(
          status: HomeStatus.failure, errorMessage: failure.message)),
      (homes) {
        emit(state.copyWith(status: HomeStatus.homesLoaded, homes: homes));
        if (homes.isNotEmpty) {
          loadDevices(homes.first.homeId);
        }
      },
    );
  }

  Future<void> loadDevices(int homeId) async {
    emit(state.copyWith(
        status: HomeStatus.loading, errorMessage: null, selectedHomeId: homeId));
    final result = await _getHomeDevices(homeId);
    result.fold(
      (failure) => emit(state.copyWith(
          status: HomeStatus.failure, errorMessage: failure.message)),
      (devices) =>
          emit(state.copyWith(status: HomeStatus.devicesLoaded, devices: devices)),
    );
  }

  Future<void> pairDevices() async {
    emit(state.copyWith(status: HomeStatus.loading, errorMessage: null));
    final result = await _pairDeviceUseCase();
    result.fold(
      (failure) => emit(state.copyWith(
          status: HomeStatus.failure, errorMessage: failure.message)),
      (_) => emit(state.copyWith(status: HomeStatus.pairing)),
    );
  }

  Future<void> controlDevice(
      {required String deviceId, required Map<String, Object> dps}) async {
    // We don't necessarily need a loading state here, to make UI feel responsive
    final result = await _controlDeviceUseCase(
      deviceId: deviceId,
      dps: dps,
    );
    result.fold(
      (failure) => emit(state.copyWith(
          status: HomeStatus.failure, errorMessage: failure.message)),
      (_) => null, // On success, we might just refresh or do nothing
    );
  }
}
