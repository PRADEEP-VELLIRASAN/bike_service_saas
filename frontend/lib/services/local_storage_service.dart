import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/service.dart';
import '../models/booking.dart';

/// Local storage service for offline-first functionality
/// Replaces API calls with local SharedPreferences storage
class LocalStorageService {
  static const String _usersKey = 'local_users';
  static const String _servicesKey = 'local_services';
  static const String _bookingsKey = 'local_bookings';
  
  SharedPreferences? _prefs;
  
  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ============================================================================
  // AUTH METHODS
  // ============================================================================

  /// Register a new user (local storage)
  Future<LocalAuthResponse> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
  }) async {
    // Check if user already exists
    final existingUsers = await _getUsers();
    if (existingUsers.any((u) => u.email.toLowerCase() == email.toLowerCase())) {
      throw LocalStorageException('A user with this email already exists');
    }
    
    // Create new user
    final user = User(
      id: _generateId(),
      email: email,
      name: name,
      phone: phone,
      role: role,
      isVerified: true,
      createdAt: DateTime.now(),
    );
    
    // Save user with password
    existingUsers.add(user);
    await _saveUsers(existingUsers);
    await _saveUserPassword(user.id, password);
    
    // Generate token and return
    final token = 'local_token_${user.id}';
    return LocalAuthResponse(accessToken: token, user: user);
  }

  /// Login with email and password (local storage)
  Future<LocalAuthResponse> login({
    required String email,
    required String password,
  }) async {
    final users = await _getUsers();
    
    final user = users.cast<User?>().firstWhere(
      (u) => u!.email.toLowerCase() == email.toLowerCase(),
      orElse: () => null,
    );
    
    if (user == null) {
      throw LocalStorageException('Invalid email or password');
    }
    
    // Verify password
    final storedPassword = await _getUserPassword(user.id);
    if (storedPassword != password) {
      throw LocalStorageException('Invalid email or password');
    }
    
    final token = 'local_token_${user.id}';
    return LocalAuthResponse(accessToken: token, user: user);
  }

  Future<List<User>> _getUsers() async {
    final p = await prefs;
    final usersJson = p.getString(_usersKey);
    if (usersJson == null) return [];
    
    final List<dynamic> list = jsonDecode(usersJson);
    return list.map((json) => User.fromJson(json)).toList();
  }

  Future<void> _saveUsers(List<User> users) async {
    final p = await prefs;
    await p.setString(_usersKey, jsonEncode(users.map((u) => u.toJson()).toList()));
  }

  Future<void> _saveUserPassword(String id, String password) async {
    final p = await prefs;
    await p.setString('password_$id', password);
  }

  Future<String?> _getUserPassword(String id) async {
    final p = await prefs;
    return p.getString('password_$id');
  }

  // ============================================================================
  // SERVICE METHODS
  // ============================================================================

  /// Get all services
  Future<ServicesResponse> getServices({bool activeOnly = true}) async {
    final services = await _getLocalServices();
    final filtered = activeOnly 
        ? services.where((s) => s.isActive).toList()
        : services;
    return ServicesResponse(services: filtered, total: filtered.length);
  }

  /// Create a new service
  Future<BikeService> createService({
    required String name,
    String? description,
    required double price,
    required int estimatedTime,
  }) async {
    final services = await _getLocalServices();
    
    final service = BikeService(
      id: _generateId(),
      name: name,
      description: description,
      price: price,
      estimatedTime: estimatedTime,
      estimatedTimeDisplay: _formatDuration(estimatedTime),
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    services.add(service);
    await _saveLocalServices(services);
    return service;
  }

  /// Update a service
  Future<BikeService> updateService({
    required String id,
    String? name,
    String? description,
    double? price,
    int? estimatedTime,
    bool? isActive,
  }) async {
    final services = await _getLocalServices();
    final index = services.indexWhere((s) => s.id == id);
    
    if (index == -1) {
      throw LocalStorageException('Service not found');
    }
    
    final existing = services[index];
    final updated = BikeService(
      id: existing.id,
      name: name ?? existing.name,
      description: description ?? existing.description,
      price: price ?? existing.price,
      estimatedTime: estimatedTime ?? existing.estimatedTime,
      estimatedTimeDisplay: _formatDuration(estimatedTime ?? existing.estimatedTime),
      isActive: isActive ?? existing.isActive,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );
    
    services[index] = updated;
    await _saveLocalServices(services);
    return updated;
  }

  /// Delete a service
  Future<void> deleteService(String id) async {
    final services = await _getLocalServices();
    services.removeWhere((s) => s.id == id);
    await _saveLocalServices(services);
  }

  Future<List<BikeService>> _getLocalServices() async {
    final p = await prefs;
    final json = p.getString(_servicesKey);
    if (json == null) {
      // Return sample services for demo
      return _getSampleServices();
    }
    
    final List<dynamic> list = jsonDecode(json);
    return list.map((j) => BikeService.fromJson(j)).toList();
  }

  Future<void> _saveLocalServices(List<BikeService> services) async {
    final p = await prefs;
    await p.setString(_servicesKey, jsonEncode(services.map((s) => s.toJson()).toList()));
  }

  // ============================================================================
  // BOOKING METHODS
  // ============================================================================

  /// Get bookings (filtered by current user for customers)
  Future<BookingsResponse> getBookings({
    String? userId,
    String? userRole,
    String? status,
    String? dateFrom,
    String? dateTo,
    int page = 1,
    int limit = 20,
  }) async {
    var bookings = await _getLocalBookings();
    
    // Filter by user if customer
    if (userRole == 'customer' && userId != null) {
      bookings = bookings.where((b) => b.customer.id == userId).toList();
    }
    
    // Filter by status
    if (status != null) {
      bookings = bookings.where((b) => b.status.apiValue == status).toList();
    }
    
    // Sort by date (newest first)
    bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return BookingsResponse(bookings: bookings, total: bookings.length);
  }

  /// Get single booking
  Future<Booking> getBooking(String id) async {
    final bookings = await _getLocalBookings();
    final booking = bookings.cast<Booking?>().firstWhere(
      (b) => b!.id == id,
      orElse: () => null,
    );
    
    if (booking == null) {
      throw LocalStorageException('Booking not found');
    }
    return booking;
  }

  /// Create a booking
  Future<Booking> createBooking({
    required String userId,
    required User customer,
    required List<String> serviceIds,
    required DateTime bookingDate,
    String? notes,
  }) async {
    final bookings = await _getLocalBookings();
    final services = await _getLocalServices();
    
    // Get selected services
    final selectedServices = services.where((s) => serviceIds.contains(s.id)).toList();
    if (selectedServices.isEmpty) {
      throw LocalStorageException('No valid services selected');
    }
    
    // Calculate total
    final totalPrice = selectedServices.fold(0.0, (sum, s) => sum + s.price);
    
    // Create booking services
    final bookingServices = selectedServices.map((s) => BookingServiceInfo(
      serviceId: s.id,
      serviceName: s.name,
      servicePrice: s.price,
    )).toList();

    final status = BookingStatus.pending;
    final booking = Booking(
      id: _generateId(),
      customer: customer,
      bookingDate: bookingDate,
      totalPrice: totalPrice,
      status: status,
      statusDisplay: status.displayName,
      notes: notes,
      services: bookingServices,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    bookings.insert(0, booking);
    await _saveLocalBookings(bookings);
    return booking;
  }

  /// Update booking status
  Future<Booking> updateBookingStatus({
    required String id,
    required String status,
  }) async {
    final bookings = await _getLocalBookings();
    final index = bookings.indexWhere((b) => b.id == id);
    
    if (index == -1) {
      throw LocalStorageException('Booking not found');
    }
    
    final existing = bookings[index];
    final newStatus = BookingStatus.values.firstWhere(
      (s) => s.apiValue == status,
      orElse: () => existing.status,
    );
    
    final updated = Booking(
      id: existing.id,
      customer: existing.customer,
      bookingDate: existing.bookingDate,
      totalPrice: existing.totalPrice,
      status: newStatus,
      statusDisplay: newStatus.displayName,
      notes: existing.notes,
      services: existing.services,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );
    
    bookings[index] = updated;
    await _saveLocalBookings(bookings);
    return updated;
  }

  /// Cancel a booking
  Future<void> cancelBooking(String id) async {
    await updateBookingStatus(id: id, status: 'cancelled');
  }

  Future<List<Booking>> _getLocalBookings() async {
    final p = await prefs;
    final json = p.getString(_bookingsKey);
    if (json == null) return [];
    
    final List<dynamic> list = jsonDecode(json);
    return list.map((j) => Booking.fromJson(j)).toList();
  }

  Future<void> _saveLocalBookings(List<Booking> bookings) async {
    final p = await prefs;
    await p.setString(_bookingsKey, jsonEncode(bookings.map((b) => b.toJson()).toList()));
  }

  // ============================================================================
  // HELPERS
  // ============================================================================

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           (DateTime.now().microsecond % 1000).toString().padLeft(3, '0');
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) return '$hours hr';
    return '$hours hr $mins min';
  }

  List<BikeService> _getSampleServices() {
    final now = DateTime.now();
    return [
      BikeService(
        id: 'sample_1',
        name: 'Basic Service',
        description: 'Oil change, chain lubrication, and basic inspection',
        price: 49.99,
        estimatedTime: 60,
        estimatedTimeDisplay: '1 hr',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      BikeService(
        id: 'sample_2',
        name: 'Full Service',
        description: 'Complete bike overhaul including brake adjustment, gear tuning, and cleaning',
        price: 99.99,
        estimatedTime: 120,
        estimatedTimeDisplay: '2 hr',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      BikeService(
        id: 'sample_3',
        name: 'Brake Service',
        description: 'Brake pad replacement and adjustment',
        price: 35.00,
        estimatedTime: 45,
        estimatedTimeDisplay: '45 min',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      BikeService(
        id: 'sample_4',
        name: 'Tire Replacement',
        description: 'Front or rear tire replacement with tube',
        price: 25.00,
        estimatedTime: 30,
        estimatedTimeDisplay: '30 min',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      BikeService(
        id: 'sample_5',
        name: 'Gear Tune-Up',
        description: 'Derailleur adjustment and cable replacement',
        price: 45.00,
        estimatedTime: 60,
        estimatedTimeDisplay: '1 hr',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  /// Initialize sample services if none exist
  Future<void> initializeSampleData() async {
    final services = await _getLocalServices();
    if (services.isEmpty || services[0].id.startsWith('sample_')) {
      await _saveLocalServices(_getSampleServices());
    }
  }
}

/// Local auth response (separate from API AuthResponse to avoid conflicts)
class LocalAuthResponse {
  final String accessToken;
  final User user;
  
  LocalAuthResponse({required this.accessToken, required this.user});
}

class ServicesResponse {
  final List<BikeService> services;
  final int total;
  
  ServicesResponse({required this.services, required this.total});
}

class BookingsResponse {
  final List<Booking> bookings;
  final int total;
  
  BookingsResponse({required this.bookings, required this.total});
}

/// Local storage exception
class LocalStorageException implements Exception {
  final String message;
  LocalStorageException(this.message);
  
  @override
  String toString() => message;
}
