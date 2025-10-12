part of 'home_cubit.dart';

enum HomeStatus { initial, loading, homesLoaded, devicesLoaded, pairing,failure }

class HomeState   {
  final HomeStatus status;
  final List<HomeEntity> homes;
  final List<DeviceEntity> devices;
  final int? selectedHomeId;
  final String? errorMessage;

  const HomeState({
    required this.status,
    required this.homes,
    required this.devices,
    required this.selectedHomeId,
    required this.errorMessage,
  });

  factory HomeState.initial() => const HomeState(
        status: HomeStatus.initial,
        homes: [],
        devices: [],
        selectedHomeId: null,
        errorMessage: null,
      );

  HomeState copyWith({
    HomeStatus? status,
    List<HomeEntity>? homes,
    List<DeviceEntity>? devices,
    int? selectedHomeId,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      homes: homes ?? this.homes,
      devices: devices ?? this.devices,
      selectedHomeId: selectedHomeId ?? this.selectedHomeId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
   List<Object?> get props => [status, homes, devices, selectedHomeId, errorMessage];

 }


