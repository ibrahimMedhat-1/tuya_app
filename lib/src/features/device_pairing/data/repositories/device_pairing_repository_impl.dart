import 'package:tuya_app/src/features/device_pairing/data/datasources/tuya_device_pairing_data_source.dart';
import 'package:tuya_app/src/features/device_pairing/domain/entities/device_pairing.dart';
import 'package:tuya_app/src/features/device_pairing/domain/repositories/device_pairing_repository.dart';

class DevicePairingRepositoryImpl implements DevicePairingRepository {
  final TuyaDevicePairingDataSource _dataSource;

  DevicePairingRepositoryImpl(this._dataSource);

  @override
  Future<PairingResult> startDevicePairing() async {
    try {
      final result = await _dataSource.startDevicePairing();
      return PairingResult(
        success: result['status'] == 'ready',
        message: result['message'] ?? 'Device pairing started',
      );
    } catch (e) {
      return PairingResult(
        success: false,
        message: 'Failed to start device pairing',
        error: e.toString(),
      );
    }
  }

  @override
  Future<QRScanResult> scanQRCode() async {
    try {
      final result = await _dataSource.scanQRCode();
      return QRScanResult(
        rawData: result['qr_result'] ?? '',
        token: result['pairing_data']?['token'] ?? '',
        type: result['pairing_data']?['type'] ?? 'qr_pairing',
        additionalData: result['pairing_data'],
      );
    } catch (e) {
      throw Exception('Failed to scan QR code: ${e.toString()}');
    }
  }

  @override
  Future<PairingResult> startWifiPairing({
    required String ssid,
    required String password,
    required String token,
  }) async {
    try {
      final result = await _dataSource.startWifiPairing(
        ssid: ssid,
        password: password,
        token: token,
      );

      final device = DevicePairing(
        id: result['id'] ?? '',
        name: result['name'] ?? 'Unknown Device',
        type: result['type'] ?? '',
        status: result['status'] ?? 'paired',
        ssid: ssid,
        token: token,
        pairedAt: DateTime.now(),
      );

      return PairingResult(
        success: result['status'] == 'paired',
        message: 'Device paired successfully',
        device: device,
      );
    } catch (e) {
      return PairingResult(
        success: false,
        message: 'Failed to pair device',
        error: e.toString(),
      );
    }
  }

  @override
  Future<PairingResult> stopDevicePairing() async {
    try {
      final result = await _dataSource.stopDevicePairing();
      return PairingResult(
        success: result['status'] == 'stopped',
        message: result['message'] ?? 'Device pairing stopped',
      );
    } catch (e) {
      return PairingResult(
        success: false,
        message: 'Failed to stop device pairing',
        error: e.toString(),
      );
    }
  }
}
