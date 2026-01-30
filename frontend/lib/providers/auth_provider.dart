import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/local_storage_service.dart';
import '../config/app_config.dart';

/// Authentication state provider using local storage
class AuthProvider with ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();
  
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null && _token != null;
  bool get isOwner => _user?.isOwner ?? false;
  bool get isCustomer => _user?.isCustomer ?? false;

  /// Initialize auth state from storage
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConfig.tokenKey);
      final userJson = prefs.getString(AppConfig.userKey);
      
      if (token != null && userJson != null) {
        _token = token;
        _user = User.fromJson(jsonDecode(userJson));
      }
      
      // Initialize sample data
      await _storage.initializeSampleData();
    } catch (e) {
      debugPrint('Error initializing auth: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Register a new user
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _storage.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
        role: role,
      );
      
      await _saveAuthData(response);
      return true;
    } on LocalStorageException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Registration failed. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login with email and password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _storage.login(
        email: email,
        password: password,
      );
      
      await _saveAuthData(response);
      return true;
    } on LocalStorageException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Login failed. Please check your credentials.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save auth data to storage
  Future<void> _saveAuthData(LocalAuthResponse response) async {
    _token = response.accessToken;
    _user = response.user;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.tokenKey, response.accessToken);
    await prefs.setString(AppConfig.userKey, jsonEncode(response.user.toJson()));
  }

  /// Logout
  Future<void> logout() async {
    _user = null;
    _token = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConfig.tokenKey);
    await prefs.remove(AppConfig.userKey);
    
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
