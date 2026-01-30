import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/user.dart';
import '../models/service.dart';
import '../models/booking.dart';

/// API Service for handling all HTTP requests
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  /// Set authentication token
  void setToken(String? token) {
    _token = token;
  }

  /// Get headers with auth token
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  /// Make a GET request
  Future<dynamic> get(String endpoint, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$endpoint')
        .replace(queryParameters: queryParams);
    
    final response = await http.get(uri, headers: _headers)
        .timeout(AppConfig.connectionTimeout);
    
    return _handleResponse(response);
  }

  /// Make a POST request
  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
    
    final response = await http.post(
      uri,
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    ).timeout(AppConfig.connectionTimeout);
    
    return _handleResponse(response);
  }

  /// Make a PUT request
  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
    
    final response = await http.put(
      uri,
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    ).timeout(AppConfig.connectionTimeout);
    
    return _handleResponse(response);
  }

  /// Make a DELETE request
  Future<dynamic> delete(String endpoint) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
    
    final response = await http.delete(uri, headers: _headers)
        .timeout(AppConfig.connectionTimeout);
    
    if (response.statusCode == 204) {
      return null;
    }
    return _handleResponse(response);
  }

  /// Handle API response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw ApiException('Unauthorized. Please login again.', 401);
    } else if (response.statusCode == 403) {
      throw ApiException('Access denied.', 403);
    } else if (response.statusCode == 404) {
      throw ApiException('Resource not found.', 404);
    } else {
      final error = jsonDecode(response.body);
      throw ApiException(
        error['detail'] ?? 'An error occurred',
        response.statusCode,
      );
    }
  }

  // ==================== AUTH ENDPOINTS ====================

  /// Register a new user
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
  }) async {
    final data = await post('/auth/register', body: {
      'email': email,
      'password': password,
      'name': name,
      'phone': phone,
      'role': role,
    });
    return AuthResponse.fromJson(data);
  }

  /// Login with email and password
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final data = await post('/auth/login', body: {
      'email': email,
      'password': password,
    });
    return AuthResponse.fromJson(data);
  }

  /// Get current user profile
  Future<User> getCurrentUser() async {
    final data = await get('/auth/me');
    return User.fromJson(data);
  }

  // ==================== SERVICE ENDPOINTS ====================

  /// Get all services
  Future<ServiceListResponse> getServices({
    bool activeOnly = true,
    int skip = 0,
    int limit = 20,
  }) async {
    final data = await get('/services', queryParams: {
      'active_only': activeOnly.toString(),
      'skip': skip.toString(),
      'limit': limit.toString(),
    });
    return ServiceListResponse.fromJson(data);
  }

  /// Get single service
  Future<BikeService> getService(String id) async {
    final data = await get('/services/$id');
    return BikeService.fromJson(data);
  }

  /// Create a new service (Owner only)
  Future<BikeService> createService({
    required String name,
    String? description,
    required double price,
    required int estimatedTime,
  }) async {
    final data = await post('/services', body: {
      'name': name,
      'description': description,
      'price': price,
      'estimated_time': estimatedTime,
    });
    return BikeService.fromJson(data);
  }

  /// Update a service (Owner only)
  Future<BikeService> updateService({
    required String id,
    String? name,
    String? description,
    double? price,
    int? estimatedTime,
    bool? isActive,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;
    if (price != null) body['price'] = price;
    if (estimatedTime != null) body['estimated_time'] = estimatedTime;
    if (isActive != null) body['is_active'] = isActive;
    
    final data = await put('/services/$id', body: body);
    return BikeService.fromJson(data);
  }

  /// Delete a service (Owner only)
  Future<void> deleteService(String id) async {
    await delete('/services/$id');
  }

  // ==================== BOOKING ENDPOINTS ====================

  /// Get bookings
  Future<BookingListResponse> getBookings({
    String? status,
    String? dateFrom,
    String? dateTo,
    int page = 1,
    int pageSize = 20,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'page_size': pageSize.toString(),
    };
    if (status != null) params['status_filter'] = status;
    if (dateFrom != null) params['date_from'] = dateFrom;
    if (dateTo != null) params['date_to'] = dateTo;
    
    final data = await get('/bookings', queryParams: params);
    return BookingListResponse.fromJson(data);
  }

  /// Get single booking
  Future<Booking> getBooking(String id) async {
    final data = await get('/bookings/$id');
    return Booking.fromJson(data);
  }

  /// Create a new booking (Customer only)
  Future<Booking> createBooking({
    required List<String> serviceIds,
    required DateTime bookingDate,
    String? notes,
  }) async {
    final data = await post('/bookings', body: {
      'service_ids': serviceIds,
      'booking_date': bookingDate.toIso8601String().split('T')[0],
      'notes': notes,
    });
    return Booking.fromJson(data);
  }

  /// Update booking status (Owner only)
  Future<Booking> updateBookingStatus({
    required String id,
    required String status,
  }) async {
    final data = await put('/bookings/$id/status', body: {
      'status': status,
    });
    return Booking.fromJson(data);
  }

  /// Cancel booking
  Future<void> cancelBooking(String id) async {
    await delete('/bookings/$id');
  }
}

/// API Exception class
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}
