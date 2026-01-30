import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../models/booking.dart';
import '../models/user.dart';
import '../services/local_storage_service.dart';
import 'auth_provider.dart';

/// Booking management provider using local storage
class BookingProvider with ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();
  
  // Reference to auth provider for getting current user
  AuthProvider? _authProvider;
  
  List<Booking> _bookings = [];
  Booking? _currentBooking;
  bool _isLoading = false;
  String? _error;
  int _totalBookings = 0;

  List<Booking> get bookings => _bookings;
  Booking? get currentBooking => _currentBooking;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalBookings => _totalBookings;

  /// Set auth provider reference
  void setAuthProvider(AuthProvider authProvider) {
    _authProvider = authProvider;
  }

  /// Filter bookings by status
  List<Booking> getBookingsByStatus(BookingStatus status) {
    return _bookings.where((b) => b.status == status).toList();
  }

  /// Load bookings
  Future<void> loadBookings({
    BookingStatus? status,
    DateTime? dateFrom,
    DateTime? dateTo,
    int page = 1,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final user = _authProvider?.user;
      final response = await _storage.getBookings(
        userId: user?.id,
        userRole: user?.role,
        status: status?.apiValue,
        dateFrom: dateFrom?.toIso8601String().split('T')[0],
        dateTo: dateTo?.toIso8601String().split('T')[0],
        page: page,
      );
      
      if (page == 1) {
        _bookings = response.bookings;
      } else {
        _bookings.addAll(response.bookings);
      }
      _totalBookings = response.total;
    } on LocalStorageException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to load bookings';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get single booking
  Future<void> getBooking(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _currentBooking = await _storage.getBooking(id);
    } on LocalStorageException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to load booking details';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new booking
  Future<bool> createBooking({
    required List<String> serviceIds,
    required DateTime bookingDate,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final user = _authProvider?.user;
      if (user == null) {
        _error = 'Please login to create a booking';
        return false;
      }
      
      final booking = await _storage.createBooking(
        userId: user.id,
        customer: user,
        serviceIds: serviceIds,
        bookingDate: bookingDate,
        notes: notes,
      );
      _bookings.insert(0, booking);
      _totalBookings++;
      return true;
    } on LocalStorageException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Failed to create booking';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update booking status (Owner only)
  Future<bool> updateBookingStatus({
    required String id,
    required BookingStatus status,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final updated = await _storage.updateBookingStatus(
        id: id,
        status: status.apiValue,
      );
      
      final index = _bookings.indexWhere((b) => b.id == id);
      if (index != -1) {
        _bookings[index] = updated;
      }
      if (_currentBooking?.id == id) {
        _currentBooking = updated;
      }
      return true;
    } on LocalStorageException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Failed to update booking status';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cancel a booking
  Future<bool> cancelBooking(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _storage.cancelBooking(id);
      final index = _bookings.indexWhere((b) => b.id == id);
      if (index != -1) {
        await loadBookings();
      }
      return true;
    } on LocalStorageException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Failed to cancel booking';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear current booking
  void clearCurrentBooking() {
    _currentBooking = null;
    notifyListeners();
  }
}
