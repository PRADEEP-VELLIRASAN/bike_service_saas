/// User model
class User {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String role;
  final bool isVerified;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    required this.isVerified,
    required this.createdAt,
  });

  bool get isOwner => role == 'owner';
  bool get isCustomer => role == 'customer';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      role: json['role'],
      isVerified: json['is_verified'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Auth response with token and user
class AuthResponse {
  final String accessToken;
  final String tokenType;
  final User user;

  AuthResponse({
    required this.accessToken,
    required this.tokenType,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
      user: User.fromJson(json['user']),
    );
  }
}
