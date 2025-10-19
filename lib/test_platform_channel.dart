import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

class PlatformChannelTest extends StatefulWidget {
  const PlatformChannelTest({super.key});

  @override
  State<PlatformChannelTest> createState() => _PlatformChannelTestState();
}

class _PlatformChannelTestState extends State<PlatformChannelTest> {
  String _status = 'Ready to test';
  bool _isLoading = false;
  String _platform = 'Unknown';
  static const MethodChannel _channel = MethodChannel('com.zerotechiot.eg/tuya_sdk');

  @override
  void initState() {
    super.initState();
    _detectPlatform();
  }

  void _detectPlatform() {
    if (Platform.isIOS) {
      _platform = 'iOS';
    } else if (Platform.isAndroid) {
      _platform = 'Android';
    } else {
      _platform = 'Other';
    }
  }

  Future<void> _testIsLoggedIn() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing isLoggedIn...';
    });

    try {
      final result = await _channel.invokeMethod('isLoggedIn');
      setState(() {
        _status = 'isLoggedIn result: $result';
      });
    } catch (e) {
      setState(() {
        _status = 'isLoggedIn error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testLogin() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing login...';
    });

    try {
      final result = await _channel.invokeMethod('login', {
        'email': 'test@example.com',
        'password': 'testpassword',
      });
      setState(() {
        _status = 'Login result: $result';
      });
    } catch (e) {
      setState(() {
        _status = 'Login error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testGetHomes() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing getHomes...';
    });

    try {
      final result = await _channel.invokeMethod('getHomes');
      setState(() {
        _status = 'getHomes result: $result';
      });
    } catch (e) {
      setState(() {
        _status = 'getHomes error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testGetHomeDevices() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing getHomeDevices...';
    });

    try {
      final result = await _channel.invokeMethod('getHomeDevices', {
        'homeId': 12345,
      });
      setState(() {
        _status = 'getHomeDevices result: $result';
      });
    } catch (e) {
      setState(() {
        _status = 'getHomeDevices error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testPairDevices() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing pairDevices...';
    });

    try {
      final result = await _channel.invokeMethod('pairDevices');
      setState(() {
        _status = 'pairDevices result: $result';
      });
    } catch (e) {
      setState(() {
        _status = 'pairDevices error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testLogout() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing logout...';
    });

    try {
      final result = await _channel.invokeMethod('logout');
      setState(() {
        _status = 'logout result: $result';
      });
    } catch (e) {
      setState(() {
        _status = 'logout error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testControlDevice() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing controlDevice...';
    });

    try {
      final result = await _channel.invokeMethod('controlDevice', {
        'deviceId': 'test_device_001',
        'dps': {'1': true},
      });
      setState(() {
        _status = 'controlDevice result: $result';
      });
    } catch (e) {
      setState(() {
        _status = 'controlDevice error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Platform Channel Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Platform: $_platform',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
              onPressed: _isLoading ? null : _testIsLoggedIn,
              child: const Text('Test isLoggedIn'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _testLogin,
              child: const Text('Test Login'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _testGetHomes,
              child: const Text('Test Get Homes'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _testGetHomeDevices,
              child: const Text('Test Get Home Devices'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _testPairDevices,
              child: const Text('Test Pair Devices'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _testLogout,
              child: const Text('Test Logout'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _testControlDevice,
              child: const Text('Test Control Device'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: PlatformChannelTest(),
  ));
}

