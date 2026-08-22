// services/supabase_service.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/content_model.dart';
import '../models/subscription_model.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Category>> getCategories({int? level, String? parentId}) async {
    var query = _supabase.from('categories').select();
    if (level != null) query = query.eq('level', level);
    if (parentId != null) query = query.eq('parent_id', parentId);
    final data = await query.order('name');
    return (data as List).map((json) => Category.fromJson(json)).toList();
  }

  Future<List<Example>> getExamples(String categoryId) async {
    final data = await _supabase
        .from('examples')
        .select('*, videos!video_id(*)')
        .eq('parent_category', categoryId);
    return (data as List).map((json) => Example.fromJson(json)).toList();
  }

  Future<List<SubscriptionModel>> getUserSubscriptions(String userId) async {
    try {
      final data = await _supabase
          .from('subscriptions')
          .select()
          .eq('user_id', userId)
          .eq('is_active', true);
      return (data as List).map((json) => SubscriptionModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('SupabaseService: Error fetching subscriptions: $e');
      return [];
    }
  }

  Stream<List<SubscriptionModel>> getSubscriptionStream(String userId) {
    return _supabase
        .from('subscriptions')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((data) {
          debugPrint('SupabaseService: Real-time event for user $userId. Row count: ${data.length}');
          return data
            .where((json) => json['is_active'] == true || json['active'] == true)
            .map((json) => SubscriptionModel.fromJson(json))
            .toList();
        });
  }

  Future<String> uploadReceipt(String userId, File file) async {
    try {
      final path = '$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      debugPrint('this is user id :  $userId');
      await _supabase.storage.from('receipts').upload(path, file);
      return _supabase.storage.from('receipts').getPublicUrl(path);
    } catch (e) {
      throw Exception('فشل رفع الإيصال: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> processAndValidateReceipt(String receiptUrl, String userId, String planName) async {
    try {
      await _supabase.from('payments').insert({
        'user_id': userId,
        'receipt_url': receiptUrl,
        'status': 'processing',
        'plan_type': planName
      });

      return {'success': true, 'message': 'تم إرسال الإيصال بنجاح. سنقوم بالتحقق منه قريباً.'};
    } catch (e) {
      return {'success': false, 'message': 'فشل إرسال الإيصال: ${e.toString()}'};
    }
  }

  Future<void> submitFeedback({required String? userId, required String message, Map<String, dynamic>? metadata}) async {
    await _supabase.from('feedback').insert({
      'user_id': userId,
      'message': message,
      'metadata': metadata ?? {},
    });
  }
}
