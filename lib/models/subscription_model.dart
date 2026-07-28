// models/subscription_model.dart
class SubscriptionModel {
  final String id;
  final String userId;
  final DateTime startDate;
  final bool isActive;

  SubscriptionModel({
    required this.id,
    required this.userId,
    required this.startDate,
    this.isActive = true,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      startDate: DateTime.parse(json['start_date']),
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'start_date': startDate.toIso8601String(),
      'is_active': isActive,
    };
  }

  bool get isValid => isActive;
}