// providers/subscription_provider.dart
import 'package:flutter/material.dart';
import '../models/subscription_model.dart';
import '../services/supabase_service.dart';
import '../config/constants.dart';

class SubscriptionProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  List<SubscriptionModel> _subscriptions = [];
  bool _isLoading = false;

  List<SubscriptionModel> get subscriptions => _subscriptions;
  bool get isLoading => _isLoading;
  bool get hasActiveSubscription => _subscriptions.any((s) => s.isActive);

  bool isPlanActive(String planName) {
    return _subscriptions.any((s) => s.planName == planName && s.isActive);
  }

  List<String> get activePlanNames {
    return _subscriptions
        .where((s) => s.isActive)
        .map((s) => AppConstants.getPlanName(s.planName))
        .toList();
  }

  String get activePlansSummary {
    final names = activePlanNames;
    if (names.isEmpty) return 'حساب مجاني';
    return names.join(' و ');
  }

  Future<void> checkSubscription(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _subscriptions = await _supabaseService.getUserSubscriptions(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  bool canAccessContent(bool isPremiumContent, {String? planType}) {
    if (!isPremiumContent) return true;
    if (planType == null) return hasActiveSubscription;
    return isPlanActive(planType);
  }

  Future<Map<String, dynamic>> processReceipt(String receiptUrl, String userId, String planName) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _supabaseService.processAndValidateReceipt(receiptUrl, userId, planName);
      // We don't call checkSubscription immediately here because verification 
      // might happen asynchronously on the server.
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
