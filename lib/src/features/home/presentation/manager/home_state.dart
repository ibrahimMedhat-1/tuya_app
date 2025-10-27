part of 'home_cubit.dart';

enum HomeStatus {
  initial,
  loading,
  homesLoaded,
  devicesLoaded,
  roomsLoaded,
  pairing,
  failure,
}

class HomeState {
  final HomeStatus status;
  final List<HomeEntity> homes;
  final List<DeviceEntity> devices;
  final List<RoomEntity> rooms;
  final int? selectedHomeId;
  final int? selectedRoomId;
  final String? errorMessage;
  final int selectedBottomNavIndex;

  const HomeState({
    required this.status,
    required this.homes,
    required this.devices,
    required this.rooms,
    required this.selectedHomeId,
    required this.selectedRoomId,
    required this.errorMessage,
    required this.selectedBottomNavIndex,
  });

  factory HomeState.initial() => const HomeState(
    status: HomeStatus.initial,
    homes: [],
    devices: [],
    rooms: [],
    selectedHomeId: null,
    selectedRoomId: null,
    errorMessage: null,
    selectedBottomNavIndex: 0,
  );

  HomeState copyWith({
    HomeStatus? status,
    List<HomeEntity>? homes,
    List<DeviceEntity>? devices,
    List<RoomEntity>? rooms,
    int? selectedHomeId,
    int? selectedRoomId,
    String? errorMessage,
    int? selectedBottomNavIndex,
  }) {
    return HomeState(
      status: status ?? this.status,
      homes: homes ?? this.homes,
      devices: devices ?? this.devices,
      rooms: rooms ?? this.rooms,
      selectedHomeId: selectedHomeId ?? this.selectedHomeId,
      selectedRoomId: selectedRoomId ?? this.selectedRoomId,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedBottomNavIndex:
          selectedBottomNavIndex ?? this.selectedBottomNavIndex,
    );
  }

  List<Object?> get props => [
    status,
    homes,
    devices,
    rooms,
    selectedHomeId,
    selectedRoomId,
    errorMessage,
    selectedBottomNavIndex,
  ];
}
