// models/subscription_model.dart

enum BookPlan {
  basicbook('أساسية'),
  firstbookAdvance('متخصصة كتاب أول'),
  secondbookAdvance('متخصصة كتاب ثاني');

  final String arabicName;
  const BookPlan(this.arabicName);

  static String getArabicName(String code) {
    if (code == 'basicbook') return BookPlan.basicbook.arabicName;
    if (code == 'firstbook_advance') return BookPlan.firstbookAdvance.arabicName;
    if (code == 'secondbook_advance') return BookPlan.secondbookAdvance.arabicName;
    return code;
  }
}

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
      planName:  BookPlan.getArabicName(json['plan_type']) , // Default or from DB
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

  bool get isValid => isActive;
}
