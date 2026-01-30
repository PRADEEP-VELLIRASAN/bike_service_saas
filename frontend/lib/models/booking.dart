import 'user.dart';

/// Booking status enum
enum BookingStatus {
  pending,
  confirmed,
  inProgress,
  readyForDelivery,
  completed,
  cancelled;

  static BookingStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return BookingStatus.pending;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'in_progress':
        return BookingStatus.inProgress;
      case 'ready_for_delivery':
        return BookingStatus.readyForDelivery;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }

  String get apiValue {
    switch (this) {
      case BookingStatus.pending:
        return 'pending';
      case BookingStatus.confirmed:
        return 'confirmed';
      case BookingStatus.inProgress:
        return 'in_progress';
      case BookingStatus.readyForDelivery:
        return 'ready_for_delivery';
      case BookingStatus.completed:
        return 'completed';
      case BookingStatus.cancelled:
        return 'cancelled';
    }
  }

  String get displayName {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.inProgress:
        return 'In Progress';
      case BookingStatus.readyForDelivery:
        return 'Ready for Delivery';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// Booking service info
class BookingServiceInfo {
  final String serviceId;
  final String serviceName;
  final double servicePrice;

  BookingServiceInfo({
    required this.serviceId,
    required this.serviceName,
    required this.servicePrice,
  });

  factory BookingServiceInfo.fromJson(Map<String, dynamic> json) {
    return BookingServiceInfo(
      serviceId: json['service_id'],
      serviceName: json['service_name'],
      servicePrice: double.parse(json['service_price'].toString()),
    );
  }
}

/// Booking model
class Booking {
  final String id;
  final User customer;
  final DateTime bookingDate;
  final BookingStatus status;
  final String statusDisplay;
  final double totalPrice;
  final String? notes;
  final List<BookingServiceInfo> services;
  final DateTime createdAt;
  final DateTime updatedAt;

  Booking({
    required this.id,
    required this.customer,
    required this.bookingDate,
    required this.status,
    required this.statusDisplay,
    required this.totalPrice,
    this.notes,
    required this.services,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      customer: User.fromJson(json['customer']),
      bookingDate: DateTime.parse(json['booking_date']),
      status: BookingStatus.fromString(json['status']),
      statusDisplay: json['status_display'] ?? '',
      totalPrice: double.parse(json['total_price'].toString()),
      notes: json['notes'],
      services: (json['services'] as List)
          .map((s) => BookingServiceInfo.fromJson(s))
          .toList(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

/// Booking list response
class BookingListResponse {
  final List<Booking> bookings;
  final int total;
  final int page;
  final int pageSize;

  BookingListResponse({
    required this.bookings,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory BookingListResponse.fromJson(Map<String, dynamic> json) {
    return BookingListResponse(
      bookings: (json['bookings'] as List)
          .map((b) => Booking.fromJson(b))
          .toList(),
      total: json['total'],
      page: json['page'],
      pageSize: json['page_size'],
    );
  }
}
