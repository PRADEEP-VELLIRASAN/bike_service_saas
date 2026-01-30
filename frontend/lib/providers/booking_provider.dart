import 'package:flutter/foundation.dart';
import '../models/booking.dart';
import '../services/api_service.dart';

/// Booking management provider
class BookingProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  
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
      final response = await _api.getBookings(
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
    } on ApiException catch (e) {
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
      _currentBooking = await _api.getBooking(id);
    } on ApiException catch (e) {
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
      final booking = await _api.createBooking(
        serviceIds: serviceIds,
        bookingDate: bookingDate,
        notes: notes,
      );
      _bookings.insert(0, booking);
      _totalBookings++;
      return true;
    } on ApiException catch (e) {
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
      final updated = await _api.updateBookingStatus(
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
    } on ApiException catch (e) {
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
      await _api.cancelBooking(id);
      final index = _bookings.indexWhere((b) => b.id == id);
      if (index != -1) {
        // Update local state to cancelled
        await loadBookings();
      }
      return true;
    } on ApiException catch (e) {
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
