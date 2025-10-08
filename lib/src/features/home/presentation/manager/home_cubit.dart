import 'package:flutter_bloc/flutter_bloc.dart';
 import 'package:tuya_app/src/features/home/domain/entities/device.dart';
import 'package:tuya_app/src/features/home/domain/entities/home.dart';
import 'package:tuya_app/src/features/home/domain/usecases/home_usecases.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetUserHomesUseCase _getUserHomes;
  final GetHomeDevicesUseCase _getHomeDevices;
  final ControlDeviceUseCase _controlDevice;
  final PairDeviceUseCase _pairDeviceUseCase;

  HomeCubit(this._getUserHomes, this._getHomeDevices, this._controlDevice,this._pairDeviceUseCase) : super(HomeState.initial());

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
  pairDevices()async{
    emit(state.copyWith(status: HomeStatus.loading, errorMessage: null));
    try {
   await _pairDeviceUseCase();
      emit(state.copyWith(status: HomeStatus.pairing));
     } catch (e) {
      emit(state.copyWith(status: HomeStatus.failure, errorMessage: e.toString()));
    }
  }
}


