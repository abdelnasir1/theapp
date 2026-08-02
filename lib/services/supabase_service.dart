// services/supabase_service.dart
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/content_model.dart';
import '../models/subscription_model.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Category>> getCategories({int? level, String? parentId}) async {
    var query = _supabase.from('categories').select();

    if (level != null) {
      query = query.eq('level', level);
    }

    if (parentId != null) {
      query = query.eq('parent_id', parentId);
    }

    final data = await query.order('name');
    return data.map((json) => Category.fromJson(json)).toList();
  }

  /// Fetches examples for a specific category, including associated video info.
  /// Solutions are now stored in a JSON column 'options' within the 'examples' table.
  Future<List<Example>> getExamples(String categoryId) async {
    final data = await _supabase
        .from('examples')
        .select('*, videos!video_id(*)')
        .eq('parent_category', categoryId);

    debugPrint(data.toString());

    return (data as List).map((json) => Example.fromJson(json)).toList();
  }

  Future<SubscriptionModel?> getActiveSubscription(String userId) async {
    try {
      final data = await _supabase
          .from('subscriptions')
          .select()
          .eq('user_id', userId)
          .eq('is_active', true)
          .limit(1)
          .maybeSingle();

      if (data == null) return null;
      return SubscriptionModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> processAndValidateReceipt(
    String receiptUrl,
    String userId,
  ) async {
    await _supabase.from('payments').insert({
      'user_id': userId,
      'receipt_url': receiptUrl,
      'status': 'processing',
    });

    try {
      // Step 2: Validate transaction (Mocked)
      const isValid = true;

      // Step 3: Update payment status
      await _supabase
          .from('payments')
          .update({
            'status': 'valid',
            'verified_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('receipt_url', receiptUrl);

      // Step 4: Activate subscription
      await activateSubscription(userId);

      return {
        'success': true,
        'is_valid': isValid,
        'message': isValid
            ? 'Transaction validated successfully'
            : 'Invalid transaction',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Processing failed: ${e.toString()}',
      };
    }
  }

  Future<void> activateSubscription(String userId) async {
    final startDate = DateTime.now();

    await _supabase.from('subscriptions').insert({
      'user_id': userId,
      'start_date': startDate.toIso8601String(),
      'is_active': true
    });

    await _supabase
        .from('profiles')
        .update({'is_subscribed': true}).eq('id', userId);
  }
}
