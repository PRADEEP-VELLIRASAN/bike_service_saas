/// Bike service model
class BikeService {
  final String id;
  final String name;
  final String? description;
  final double price;
  final int estimatedTime;
  final String estimatedTimeDisplay;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  BikeService({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.estimatedTime,
    required this.estimatedTimeDisplay,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BikeService.fromJson(Map<String, dynamic> json) {
    return BikeService(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      estimatedTime: json['estimated_time'],
      estimatedTimeDisplay: json['estimated_time_display'] ?? '${json['estimated_time']}m',
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'estimated_time': estimatedTime,
      'is_active': isActive,
    };
  }
}

/// Service list response
class ServiceListResponse {
  final List<BikeService> services;
  final int total;

  ServiceListResponse({
    required this.services,
    required this.total,
  });

  factory ServiceListResponse.fromJson(Map<String, dynamic> json) {
    return ServiceListResponse(
      services: (json['services'] as List)
          .map((s) => BikeService.fromJson(s))
          .toList(),
      total: json['total'],
    );
  }
}
