import 'package:flutter/material.dart';
import 'tuya_sdk_plugin.dart';
import 'presentation/pages/device_pairing_page.dart';

class TuyaSDKDemo extends StatefulWidget {
  const TuyaSDKDemo({Key? key}) : super(key: key);

  @override
  State<TuyaSDKDemo> createState() => _TuyaSDKDemoState();
}

class _TuyaSDKDemoState extends State<TuyaSDKDemo> {
  bool _isInitialized = false;
  bool _isLoggedIn = false;
  String _statusMessage = 'SDK not initialized';
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _countryCodeController = TextEditingController(text: '1');
  
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _initializeSDK() async {
    // Using the same App Key and App Secret from TuyaSmartApplication
    const appKey = 'xvtf3fqw93d37sucppkn';
    const appSecret = 'k8u9edtefgrwcmxqaesra9gmmpuh8uy';
    
    try {
      final result = await TuyaSdkPlugin.initTuyaSDK(
        appKey: appKey,
        appSecret: appSecret,
        packageName: 'com.zerotechiot.smart_home_tuya',
      );
      
      setState(() {
        _isInitialized = result;
        _statusMessage = result 
            ? 'SDK initialized successfully'
            : 'SDK initialization failed';
      });
      
      await _checkLoginStatus();
    } catch (e) {
      setState(() {
        _statusMessage = 'Error initializing SDK: $e';
      });
    }
  }
  
  Future<void> _checkLoginStatus() async {
    try {
      final isLoggedIn = await TuyaSdkPlugin.isLoggedIn();
      setState(() {
        _isLoggedIn = isLoggedIn;
        if (isLoggedIn) {
          _statusMessage = 'User is logged in';
        }
      });
    } catch (e) {
      debugPrint('Error checking login status: $e');
    }
  }
  
  Future<void> _registerUser() async {
    if (!_isInitialized) {
      _showMessage('Please initialize SDK first');
      return;
    }
    
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showMessage('Please enter email and password');
      return;
    }
    
    try {
      setState(() {
        _statusMessage = 'Registering user...';
      });
      
      final userData = await TuyaSdkPlugin.registerWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
        countryCode: _countryCodeController.text,
      );
      
      setState(() {
        _userData = userData;
        _statusMessage = 'Registration successful';
        _isLoggedIn = true;
      });
      
      _showMessage('Registration successful! User ID: ${userData?['id']}');
    } catch (e) {
      setState(() {
        _statusMessage = 'Registration error: $e';
      });
      _showMessage('Registration failed: $e');
    }
  }
  
  Future<void> _loginUser() async {
    if (!_isInitialized) {
      _showMessage('Please initialize SDK first');
      return;
    }
    
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showMessage('Please enter email and password');
      return;
    }
    
    try {
      setState(() {
        _statusMessage = 'Logging in...';
      });
      
      final userData = await TuyaSdkPlugin.loginWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
        countryCode: _countryCodeController.text,
      );
      
      setState(() {
        _userData = userData;
        _statusMessage = 'Login successful';
        _isLoggedIn = true;
      });
      
      _showMessage('Login successful! User ID: ${userData?['id']}');
    } catch (e) {
      setState(() {
        _statusMessage = 'Login error: $e';
      });
      _showMessage('Login failed: $e');
    }
  }
  
  Future<void> _logoutUser() async {
    if (!_isLoggedIn) {
      _showMessage('No user is logged in');
      return;
    }
    
    try {
      setState(() {
        _statusMessage = 'Logging out...';
      });
      
      await TuyaSdkPlugin.logout();
      
      setState(() {
        _userData = null;
        _statusMessage = 'Logout successful';
        _isLoggedIn = false;
      });
      
      _showMessage('Logout successful');
    } catch (e) {
      setState(() {
        _statusMessage = 'Logout error: $e';
      });
      _showMessage('Logout failed: $e');
    }
  }
  
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tuya SDK Demo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Status: $_statusMessage',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _initializeSDK,
              child: const Text('Initialize SDK'),
            ),
            const Divider(height: 30),
            TextField(
              controller: _countryCodeController,
              decoration: const InputDecoration(
                labelText: 'Country Code',
                hintText: 'e.g., 1 for US',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isInitialized ? _registerUser : null,
                    child: const Text('Register'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isInitialized ? _loginUser : null,
                    child: const Text('Login'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isLoggedIn ? _logoutUser : null,
              child: const Text('Logout'),
            ),
            if (_userData != null) ...[
              const Divider(height: 30),
              const Text(
                'User Data:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text('ID: ${_userData?['id'] ?? 'N/A'}'),
              Text('Email: ${_userData?['email'] ?? 'N/A'}'),
              Text('Username: ${_userData?['username'] ?? 'N/A'}'),
            ],
            const Divider(height: 30),
            const Text(
              'iOS Activities:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isLoggedIn ? () => TuyaSdkPlugin.openHomeActivity() : null,
              child: const Text('Open Home Activity'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isLoggedIn ? () => TuyaSdkPlugin.openAddDeviceActivity() : null,
              child: const Text('Open Add Device Activity'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isLoggedIn ? () => TuyaSdkPlugin.openSettingsActivity() : null,
              child: const Text('Open Settings Activity'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoggedIn ? () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const DevicePairingPage()),
                );
              } : null,
              child: const Text('Open Device Pairing Page'),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _countryCodeController.dispose();
    super.dispose();
  }
} 