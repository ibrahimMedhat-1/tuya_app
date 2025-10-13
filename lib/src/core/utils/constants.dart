import 'package:flutter/services.dart';

abstract class AppConstants{
  static const MethodChannel channel = MethodChannel(
    'com.zerotechiot.eg/tuya_sdk',
  );
}