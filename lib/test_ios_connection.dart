import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Test widget to verify Flutter <-> iOS MethodChannel connection
class TestIOSConnection extends StatefulWidget {
  const TestIOSConnection({super.key});

  @override
  State<TestIOSConnection> createState() => _TestIOSConnectionState();
}

class _TestIOSConnectionState extends State<TestIOSConnection> {
  static const MethodChannel _channel = MethodChannel('com.zerotechiot.eg/tuya_sdk');
  String _testResult = 'Not tested yet';
  bool _isLoading = false;

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Testing...';
    });

    try {
      print('🔵 [Flutter] Calling test_ios_connection...');
      
      final result = await _channel.invokeMethod('test_ios_connection');
      
      print('✅ [Flutter] Got response from iOS: $result');
      
      setState(() {
        _testResult = '✅ SUCCESS!\n\nResponse from iOS:\n$result';
        _isLoading = false;
      });
    } on PlatformException catch (e) {
      print('❌ [Flutter] PlatformException: ${e.message} (code: ${e.code})');
      setState(() {
        _testResult = '❌ FAILED!\n\nPlatformException:\n${e.message}';
        _isLoading = false;
      });
    } on MissingPluginException catch (e) {
      print('❌ [Flutter] MissingPluginException: $e');
      setState(() {
        _testResult = '❌ FAILED!\n\nMethodChannel handler NOT registered on iOS!\n\n$e';
        _isLoading = false;
      });
    } catch (e) {
      print('❌ [Flutter] Unexpected error: $e');
      setState(() {
        _testResult = '❌ FAILED!\n\nUnexpected error:\n$e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test iOS Connection'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.cable,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 32),
              const Text(
                'Flutter <-> iOS Connection Test',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'This will test if the MethodChannel is properly set up',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: _isLoading ? null : _testConnection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Test Connection'),
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _testResult,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

