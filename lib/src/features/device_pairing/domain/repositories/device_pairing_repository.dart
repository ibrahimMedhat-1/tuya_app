import 'package:tuya_app/src/features/device_pairing/domain/entities/device_pairing.dart';

abstract class DevicePairingRepository {
  Future<PairingResult> startDevicePairing();
  Future<QRScanResult> scanQRCode();
  Future<PairingResult> startWifiPairing({
    required String ssid,
    required String password,
    required String token,
  });
  Future<PairingResult> stopDevicePairing();
}
