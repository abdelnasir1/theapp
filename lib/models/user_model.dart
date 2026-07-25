// models/user_model.dart
class UserModel {
  final String id;
  final String email;
  final String fullName;
  final bool isSubscribed;
  final DateTime? subscriptionExpiry;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.isSubscribed = false,
    this.subscriptionExpiry,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      isSubscribed: json['is_subscribed'] ?? false,
      subscriptionExpiry: json['subscription_expiry'] != null
          ? DateTime.parse(json['subscription_expiry'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'is_subscribed': isSubscribed,
      'subscription_expiry': subscriptionExpiry?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }
}