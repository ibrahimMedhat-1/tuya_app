class DevicePairing {
  final String id;
  final String name;
  final String type;
  final String status;
  final String? ssid;
  final String? token;
  final String? qrData;
  final DateTime? pairedAt;

  const DevicePairing({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    this.ssid,
    this.token,
    this.qrData,
    this.pairedAt,
  });

  factory DevicePairing.fromJson(Map<String, dynamic> json) {
    return DevicePairing(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      ssid: json['ssid'],
      token: json['token'],
      qrData: json['qrData'],
      pairedAt: json['pairedAt'] != null
          ? DateTime.parse(json['pairedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'status': status,
      'ssid': ssid,
      'token': token,
      'qrData': qrData,
      'pairedAt': pairedAt?.toIso8601String(),
    };
  }
}

class PairingResult {
  final bool success;
  final String message;
  final DevicePairing? device;
  final String? error;

  const PairingResult({
    required this.success,
    required this.message,
    this.device,
    this.error,
  });

  factory PairingResult.fromJson(Map<String, dynamic> json) {
    return PairingResult(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      device: json['device'] != null
          ? DevicePairing.fromJson(json['device'])
          : null,
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'device': device?.toJson(),
      'error': error,
    };
  }
}

class QRScanResult {
  final String rawData;
  final String token;
  final String type;
  final Map<String, dynamic>? additionalData;

  const QRScanResult({
    required this.rawData,
    required this.token,
    required this.type,
    this.additionalData,
  });

  factory QRScanResult.fromJson(Map<String, dynamic> json) {
    return QRScanResult(
      rawData: json['rawData'] ?? '',
      token: json['token'] ?? '',
      type: json['type'] ?? '',
      additionalData: json['additionalData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rawData': rawData,
      'token': token,
      'type': type,
      'additionalData': additionalData,
    };
  }
}
