import 'package:flutter/foundation.dart';
import '../models/service.dart';
import '../services/api_service.dart';

/// Service management provider
class ServiceProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  
  List<BikeService> _services = [];
  bool _isLoading = false;
  String? _error;

  List<BikeService> get services => _services;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all services
  Future<void> loadServices({bool activeOnly = true}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _api.getServices(activeOnly: activeOnly);
      _services = response.services;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to load services';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new service
  Future<bool> createService({
    required String name,
    String? description,
    required double price,
    required int estimatedTime,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final service = await _api.createService(
        name: name,
        description: description,
        price: price,
        estimatedTime: estimatedTime,
      );
      _services.insert(0, service);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Failed to create service';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update a service
  Future<bool> updateService({
    required String id,
    String? name,
    String? description,
    double? price,
    int? estimatedTime,
    bool? isActive,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final updated = await _api.updateService(
        id: id,
        name: name,
        description: description,
        price: price,
        estimatedTime: estimatedTime,
        isActive: isActive,
      );
      
      final index = _services.indexWhere((s) => s.id == id);
      if (index != -1) {
        _services[index] = updated;
      }
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Failed to update service';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a service
  Future<bool> deleteService(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _api.deleteService(id);
      _services.removeWhere((s) => s.id == id);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Failed to delete service';
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
}
