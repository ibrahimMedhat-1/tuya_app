import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

void main() {
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zero Code - Platform Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const PlatformIntegrationTest(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Test script to verify platform channel integration
class PlatformIntegrationTest extends StatefulWidget {
  const PlatformIntegrationTest({super.key});

  @override
  State<PlatformIntegrationTest> createState() => _PlatformIntegrationTestState();
}

class _PlatformIntegrationTestState extends State<PlatformIntegrationTest> {
  static const MethodChannel _channel = MethodChannel('com.zerotechiot.eg/tuya_sdk');
  
  String _status = 'Ready to test';
  bool _isLoading = false;
  String _platform = 'Unknown';

  @override
  Widget build(BuildContext context) {
    // Detect platform using dart:io
    if (Platform.isIOS) {
      _platform = 'iOS';
    } else if (Platform.isAndroid) {
      _platform = 'Android';
    } else {
      _platform = 'Other';
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Platform Integration Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Platform: $_platform',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text('Status: $_status'),
                    if (_isLoading) ...[
                      const SizedBox(height: 16),
                      const LinearProgressIndicator(),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _testLogin,
              child: const Text('Test Login'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _testIsLoggedIn,
              child: const Text('Test Is Logged In'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _testGetHomes,
              child: const Text('Test Get Homes'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _testPairDevices,
              child: const Text('Test Pair Devices'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _testOpenDevicePanel,
              child: const Text('Test Open Device Panel'),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Instructions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Test Login: Try logging in with valid credentials\n'
                      '2. Test Is Logged In: Check current login status\n'
                      '3. Test Get Homes: Retrieve user homes (requires login)\n'
                      '4. Test Pair Devices: Open device pairing UI\n'
                      '5. Test Open Device Panel: Open device control panel',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  void _updateStatus(String status) {
    setState(() {
      _status = status;
    });
  }

  Future<void> _testLogin() async {
    _setLoading(true);
    _updateStatus('Testing login...');
    
    try {
      final result = await _channel.invokeMethod('login', {
        'email': 'test@example.com',
        'password': 'testpassword',
      });
      
      _updateStatus('Login test completed. Result: $result');
    } on PlatformException catch (e) {
      _updateStatus('Login test failed: ${e.message}');
    } catch (e) {
      _updateStatus('Login test error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _testIsLoggedIn() async {
    _setLoading(true);
    _updateStatus('Testing is logged in...');
    
    try {
      final result = await _channel.invokeMethod('isLoggedIn');
      _updateStatus('Is logged in test completed. Result: $result');
    } on PlatformException catch (e) {
      _updateStatus('Is logged in test failed: ${e.message}');
    } catch (e) {
      _updateStatus('Is logged in test error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _testGetHomes() async {
    _setLoading(true);
    _updateStatus('Testing get homes...');
    
    try {
      final result = await _channel.invokeMethod('getHomes');
      _updateStatus('Get homes test completed. Result: $result');
    } on PlatformException catch (e) {
      _updateStatus('Get homes test failed: ${e.message}');
    } catch (e) {
      _updateStatus('Get homes test error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _testPairDevices() async {
    _setLoading(true);
    _updateStatus('Testing pair devices...');
    
    try {
      final result = await _channel.invokeMethod('pairDevices');
      _updateStatus('Pair devices test completed. Result: $result');
    } on PlatformException catch (e) {
      _updateStatus('Pair devices test failed: ${e.message}');
    } catch (e) {
      _updateStatus('Pair devices test error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _testOpenDevicePanel() async {
    _setLoading(true);
    _updateStatus('Testing open device panel...');
    
    try {
      final result = await _channel.invokeMethod('openDeviceControlPanel', {
        'deviceId': 'test_device_id',
        'homeId': 123,
        'homeName': 'Test Home',
      });
      _updateStatus('Open device panel test completed. Result: $result');
    } on PlatformException catch (e) {
      _updateStatus('Open device panel test failed: ${e.message}');
    } catch (e) {
      _updateStatus('Open device panel test error: $e');
    } finally {
      _setLoading(false);
    }
  }
}

