// providers/subscription_provider.dart
import 'package:flutter/material.dart';
import '../models/subscription_model.dart';
import '../services/supabase_service.dart';

class SubscriptionProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  SubscriptionModel? _subscription;
  bool _isLoading = false;
  bool _hasActiveSubscription = false;

  SubscriptionModel? get subscription => _subscription;
  bool get isLoading => _isLoading;
  bool get hasActiveSubscription => _hasActiveSubscription;

  Future<void> checkSubscription(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _subscription = await _supabaseService.getActiveSubscription(userId);
      _hasActiveSubscription = _subscription != null ;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  bool canAccessContent(bool isPremiumContent) {
    if (!isPremiumContent) return true;
    return _hasActiveSubscription;
  }

  Future<void> processReceipt(String receiptUrl, String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Process OCR and validate receipt
      await _supabaseService.processAndValidateReceipt(receiptUrl, userId);
      await checkSubscription(userId);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}