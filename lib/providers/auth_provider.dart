import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> login(String mobileNumber, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      
      await _storage.write(key: 'auth_token', value: 'dummy_token_${DateTime.now().millisecondsSinceEpoch}');
      await _storage.write(key: 'mobile_number', value: mobileNumber);
      
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Login failed. Please try again.';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'mobile_number');
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<String?> getAuthToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<void> checkAuthStatus() async {
    final token = await getAuthToken();
    _isAuthenticated = token != null;
    notifyListeners();
  }
}
