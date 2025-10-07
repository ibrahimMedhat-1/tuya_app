import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tuya_app/src/features/device_pairing/domain/entities/device_pairing.dart';
import 'package:tuya_app/src/features/device_pairing/domain/repositories/device_pairing_repository.dart';

// Events
abstract class DevicePairingEvent {}

class StartDevicePairingEvent extends DevicePairingEvent {}

class ScanQRCodeEvent extends DevicePairingEvent {}

class StartWifiPairingEvent extends DevicePairingEvent {
  final String ssid;
  final String password;
  final String token;

  StartWifiPairingEvent({
    required this.ssid,
    required this.password,
    required this.token,
  });
}

class StopDevicePairingEvent extends DevicePairingEvent {}

// States
abstract class DevicePairingState {}

class DevicePairingInitial extends DevicePairingState {}

class DevicePairingLoading extends DevicePairingState {}

class DevicePairingReady extends DevicePairingState {}

class DevicePairingSuccess extends DevicePairingState {
  final DevicePairing? device;
  final String message;

  DevicePairingSuccess({this.device, required this.message});
}

class DevicePairingError extends DevicePairingState {
  final String message;

  DevicePairingError({required this.message});
}

// Cubit
class DevicePairingCubit extends Bloc<DevicePairingEvent, DevicePairingState> {
  final DevicePairingRepository _repository;

  DevicePairingCubit(this._repository) : super(DevicePairingInitial()) {
    on<StartDevicePairingEvent>(_onStartDevicePairing);
    on<ScanQRCodeEvent>(_onScanQRCode);
    on<StartWifiPairingEvent>(_onStartWifiPairing);
    on<StopDevicePairingEvent>(_onStopDevicePairing);
  }

  Future<void> _onStartDevicePairing(
    StartDevicePairingEvent event,
    Emitter<DevicePairingState> emit,
  ) async {
    emit(DevicePairingLoading());
    try {
      final result = await _repository.startDevicePairing();
      if (result.success) {
        emit(DevicePairingReady());
      } else {
        emit(DevicePairingError(message: result.message));
      }
    } catch (e) {
      emit(DevicePairingError(message: e.toString()));
    }
  }

  Future<void> _onScanQRCode(
    ScanQRCodeEvent event,
    Emitter<DevicePairingState> emit,
  ) async {
    emit(DevicePairingLoading());
    try {
      final result = await _repository.scanQRCode();
      // For now, just show success - in a real app, you might want to
      // automatically start WiFi pairing with the scanned token
      emit(
        DevicePairingSuccess(
          message: 'QR code scanned successfully. Token: ${result.token}',
        ),
      );
    } catch (e) {
      emit(DevicePairingError(message: e.toString()));
    }
  }

  Future<void> _onStartWifiPairing(
    StartWifiPairingEvent event,
    Emitter<DevicePairingState> emit,
  ) async {
    emit(DevicePairingLoading());
    try {
      final result = await _repository.startWifiPairing(
        ssid: event.ssid,
        password: event.password,
        token: event.token,
      );
      if (result.success) {
        emit(
          DevicePairingSuccess(device: result.device, message: result.message),
        );
      } else {
        emit(DevicePairingError(message: result.message));
      }
    } catch (e) {
      emit(DevicePairingError(message: e.toString()));
    }
  }

  Future<void> _onStopDevicePairing(
    StopDevicePairingEvent event,
    Emitter<DevicePairingState> emit,
  ) async {
    emit(DevicePairingLoading());
    try {
      final result = await _repository.stopDevicePairing();
      if (result.success) {
        emit(DevicePairingReady());
      } else {
        emit(DevicePairingError(message: result.message));
      }
    } catch (e) {
      emit(DevicePairingError(message: e.toString()));
    }
  }

  // Convenience methods
  void startDevicePairing() => add(StartDevicePairingEvent());
  void scanQRCode() => add(ScanQRCodeEvent());
  void startWifiPairing({
    required String ssid,
    required String password,
    required String token,
  }) =>
      add(StartWifiPairingEvent(ssid: ssid, password: password, token: token));
  void stopDevicePairing() => add(StopDevicePairingEvent());
}
