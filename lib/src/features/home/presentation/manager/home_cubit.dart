import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tuya_app/src/features/home/domain/entities/device.dart';
import 'package:tuya_app/src/features/home/domain/entities/home.dart';
import 'package:tuya_app/src/features/home/domain/entities/room.dart';
import 'package:tuya_app/src/features/home/domain/usecases/home_usecases.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetUserHomesUseCase _getUserHomes;
  final GetHomeDevicesUseCase _getHomeDevices;
  final GetHomeRoomsUseCase _getHomeRooms;
  final GetRoomDevicesUseCase _getRoomDevices;
  final AddHouseUseCase _addHouse;
  final AddRoomUseCase _addRoom;
  final ControlDeviceUseCase _controlDeviceUseCase;
  final PairDeviceUseCase _pairDeviceUseCase;

  HomeCubit(
    this._getUserHomes,
    this._getHomeDevices,
    this._getHomeRooms,
    this._getRoomDevices,
    this._addHouse,
    this._addRoom,
    this._controlDeviceUseCase,
    this._pairDeviceUseCase,
  ) : super(HomeState.initial());

  Future<void> loadHomes() async {
    emit(state.copyWith(status: HomeStatus.loading, errorMessage: null));
    final result = await _getUserHomes();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (homes) {
        emit(state.copyWith(status: HomeStatus.homesLoaded, homes: homes));
        if (homes.isNotEmpty) {
          loadDevices(homes.first.homeId);
          loadRooms(homes.first.homeId);
        }
      },
    );
  }

  Future<void> loadDevices(int homeId) async {
    emit(
      state.copyWith(
        status: HomeStatus.loading,
        errorMessage: null,
        selectedHomeId: homeId,
      ),
    );

    // Get the home name to pass to Android for BizBundle context
    final homeName = state.homes
        .firstWhere(
          (home) => home.homeId == homeId,
          orElse: () => state.homes.first,
        )
        .name;

    final result = await _getHomeDevices(homeId, homeName: homeName);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (devices) => emit(
        state.copyWith(status: HomeStatus.devicesLoaded, devices: devices),
      ),
    );
  }

  Future<void> loadRooms(int homeId) async {
    emit(
      state.copyWith(
        status: HomeStatus.loading,
        errorMessage: null,
        selectedHomeId: homeId,
      ),
    );

    final result = await _getHomeRooms(homeId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (rooms) =>
          emit(state.copyWith(status: HomeStatus.roomsLoaded, rooms: rooms)),
    );
  }

  Future<void> selectRoom(int homeId, int roomId) async {
    emit(
      state.copyWith(
        status: HomeStatus.loading,
        errorMessage: null,
        selectedHomeId: homeId,
        selectedRoomId: roomId,
      ),
    );

    final result = await _getRoomDevices(homeId, roomId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (devices) => emit(
        state.copyWith(
          status: HomeStatus.devicesLoaded,
          devices: devices,
          selectedRoomId: roomId,
        ),
      ),
    );
  }

  Future<void> loadAllHomeDevices(int homeId) async {
    emit(
      state.copyWith(
        status: HomeStatus.loading,
        errorMessage: null,
        selectedHomeId: homeId,
        selectedRoomId: null, // Clear room selection
      ),
    );

    final result = await _getHomeDevices(homeId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (devices) => emit(
        state.copyWith(
          status: HomeStatus.devicesLoaded,
          devices: devices,
          selectedRoomId: null,
        ),
      ),
    );
  }

  Future<void> pairDevices() async {
    emit(state.copyWith(status: HomeStatus.loading, errorMessage: null));
    final result = await _pairDeviceUseCase();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(state.copyWith(status: HomeStatus.pairing)),
    );
  }

  Future<void> controlDevice({
    required String deviceId,
    required Map<String, Object> dps,
  }) async {
    // We don't necessarily need a loading state here, to make UI feel responsive
    final result = await _controlDeviceUseCase(deviceId: deviceId, dps: dps);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => null, // On success, we might just refresh or do nothing
    );
  }

  Future<void> addHouse({
    required String name,
    String? geoName,
    double? lon,
    double? lat,
    List<String>? roomNames,
  }) async {
    emit(state.copyWith(status: HomeStatus.loading, errorMessage: null));
    final result = await _addHouse(
      name: name,
      geoName: geoName,
      lon: lon,
      lat: lat,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (home) async {
        // Add the new home to the list
        final updatedHomes = [...state.homes, home];
        emit(
          state.copyWith(
            status: HomeStatus.homesLoaded,
            homes: updatedHomes,
            selectedHomeId: home.homeId,
          ),
        );

        // Create rooms if provided
        if (roomNames != null && roomNames.isNotEmpty) {
          for (final roomName in roomNames) {
            await _addRoom(homeId: home.homeId, name: roomName);
          }
        }

        // Load rooms for the new home
        loadRooms(home.homeId);
      },
    );
  }

  Future<void> addRoom({
    required int homeId,
    required String name,
    String? iconUrl,
  }) async {
    emit(state.copyWith(status: HomeStatus.loading, errorMessage: null));
    final result = await _addRoom(homeId: homeId, name: name, iconUrl: iconUrl);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (room) {
        // Add the new room to the list
        final updatedRooms = [...state.rooms, room];
        emit(
          state.copyWith(status: HomeStatus.roomsLoaded, rooms: updatedRooms),
        );
      },
    );
  }
}
