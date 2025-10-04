import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tuya_sdk_plugin.dart';
import 'demo_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Tuya SDK with platform-specific keys
  try {
    final result = await TuyaSdkPlugin.initTuyaSDK(
      appKey: 'xvtf3fqw93d37sucppkn', 
      appSecret: 'k8u9edtefgrwcmxqaesra9gmmpuh8uy',
      packageName: 'com.zerotechiot.smart_home_tuya',
    );
    
    print('Tuya SDK v3.25.0 initialized: $result');
  } catch (e) {
    print('Error initializing Tuya SDK: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tuya Smart Home',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const TuyaSDKDemo(),
    );
  }
}
