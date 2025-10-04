import '../services/tuya_sdk_service.dart';

class TuyaAuthDataSource {
  final TuyaSDKService _service = TuyaSDKService();
  bool _isInitialized = false;
  
  // Ensure SDK is initialized before any operations
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      _isInitialized = await _service.initSDK();
      if (!_isInitialized) {
        throw Exception('Failed to initialize Tuya SDK');
      }
    }
  }
  
  Future<Map<String, dynamic>> loginWithEmail(String email, String password) async {
    await _ensureInitialized();
    
    try {
      final user = await _service.loginWithEmail(email, password, '1'); // US code default
      
      if (user == null) {
        throw Exception('Login failed: No user data returned');
      }
      
      return {
        'id': user.id,
        'email': user.email,
        'username': user.username,
      };
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }
  
  Future<Map<String, dynamic>> registerWithEmail(String email, String password, String countryCode) async {
    await _ensureInitialized();
    
    try {
      final user = await _service.registerWithEmail(email, password, countryCode);
      
      if (user == null) {
        throw Exception('Registration failed: No user data returned');
      }
      
      return {
        'id': user.id,
        'email': user.email,
        'username': user.username,
      };
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }
  
  Future<void> logout() async {
    await _ensureInitialized();
    
    try {
      await _service.logout();
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }
  
  Future<bool> isLoggedIn() async {
    await _ensureInitialized();
    
    try {
      return await _service.isLoggedIn();
    } catch (e) {
      throw Exception('Check login status failed: ${e.toString()}');
    }
  }
} 