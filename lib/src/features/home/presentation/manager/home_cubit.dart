import 'package:flutter_bloc/flutter_bloc.dart';
 import 'package:tuya_app/src/features/home/domain/entities/device.dart';
import 'package:tuya_app/src/features/home/domain/entities/home.dart';
import 'package:tuya_app/src/features/home/domain/usecases/home_usecases.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetUserHomesUseCase _getUserHomes;
  final GetHomeDevicesUseCase _getHomeDevices;
  final ControlDeviceUseCase _controlDevice;

  HomeCubit(this._getUserHomes, this._getHomeDevices, this._controlDevice) : super(HomeState.initial());

  Future<void> loadHomes() async {
    emit(state.copyWith(status: HomeStatus.loading, errorMessage: null));
    try {
      final homes = await _getUserHomes();
      emit(state.copyWith(status: HomeStatus.homesLoaded, homes: homes));
      loadDevices(homes.first.homeId);
    } catch (e) {
      emit(state.copyWith(status: HomeStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> loadDevices(int homeId) async {
    emit(state.copyWith(status: HomeStatus.loading, errorMessage: null, selectedHomeId: homeId));
    try {
      final devices = await _getHomeDevices(homeId);
      emit(state.copyWith(status: HomeStatus.devicesLoaded, devices: devices));
    } catch (e) {
      emit(state.copyWith(status: HomeStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> toggleDevice(String deviceId, bool on) async {
    try {
      await _controlDevice(deviceId: deviceId, dps: { "1": on });
      final updated = state.devices.map((d) {
        if (d.deviceId == deviceId) {
          return d.copyWith(
            currentState: {...d.currentState, "1": on},
          );
        }
        return d;
      }).toList();
      emit(state.copyWith(devices: updated));
    } catch (e) {
      emit(state.copyWith(status: HomeStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> controlDevice(String deviceId, Map<String, Object> dps) async {
    try {
      await _controlDevice(deviceId: deviceId, dps: dps);
      final updated = state.devices.map((d) {
        if (d.deviceId == deviceId) {
          return d.copyWith(
            currentState: {...d.currentState, ...dps},
          );
        }
        return d;
      }).toList();
      emit(state.copyWith(devices: updated));
    } catch (e) {
      emit(state.copyWith(status: HomeStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> setBrightness(String deviceId, int brightness) async {
    await controlDevice(deviceId, {"2": brightness});
  }

  Future<void> setColor(String deviceId, String color) async {
    await controlDevice(deviceId, {"4": color});
  }

  Future<void> setTemperature(String deviceId, int temperature) async {
    await controlDevice(deviceId, {"3": temperature});
  }
}


