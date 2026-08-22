// models/subscription_model.dart
class SubscriptionModel {
  final String id;
  final String userId;
  final DateTime startDate;
  final bool isActive;
  final String planName; // Added planName

  SubscriptionModel({
    required this.id,
    required this.userId,
    required this.startDate,
    this.isActive = true,
    required this.planName,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      startDate: DateTime.parse(json['start_date']),
      isActive: json['is_active'] ?? true,
      planName:  json['plan_type'] , // Default or from DB
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'start_date': startDate.toIso8601String(),
      'is_active': isActive,
      'plan_name': planName,
    };
  }
}
