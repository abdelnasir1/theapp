// services/supabase_service.dart
import 'dart:io';
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

  Future<List<Video>> getVideos(String categoryId) async {
    final data = await _supabase
        .from('videos')
        .select()
        .eq('category_id', categoryId)
        .order('title');

    return data.map((json) => Video.fromJson(json)).toList();
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
    // Step 1: Upload receipt to Supabase Storage
    final storageResponse = await _supabase.storage
        .from('receipts')
        .upload(
      'receipts/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg',
      receiptUrl as File,
    );

    final publicUrl = _supabase.storage
        .from('receipts')
        .getPublicUrl(storageResponse);

    // Step 2: Create payment record
    await _supabase.from('payments').insert({
      'user_id': userId,
      'receipt_url': publicUrl,
      'status': 'processing',
    });

    // Step 3: Process OCR via Edge Function
    try {
      final ocrResponse = await _supabase.functions.invoke(
        'process-receipt-ocr',
        body: {
          'receipt_url': publicUrl,
          'user_id': userId,
        },
      );

      final ocrData = ocrResponse.data;

      // Step 4: Validate transaction
      final isValid = await validateTransaction(ocrData);

      // Step 5: Update payment status
      await _supabase
          .from('payments')
          .update({
        'status': isValid ? 'valid' : 'invalid',
        'verified_at': DateTime.now().toIso8601String(),
      })
          .eq('user_id', userId)
          .eq('receipt_url', publicUrl);

      if (isValid) {
        // Activate subscription
        await activateSubscription(userId);
      }

      return {
        'success': true,
        'is_valid': isValid,
        'message': isValid ? 'Transaction validated successfully' : 'Invalid transaction',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'OCR processing failed: ${e.toString()}',
      };
    }
  }

  Future<bool> validateTransaction(dynamic ocrData) async {
    // Implement validation logic based on OCR data
    // Check amount, date, transaction ID against your database
    // This is a simplified example
    try {
      final data = ocrData as Map<String, dynamic>;
      final amount = double.tryParse(data['amount']?.toString() ?? '0');

      // Validate against expected amounts
      const validAmounts = [9.99, 19.99, 29.99]; // Your subscription prices

      return amount != null && validAmounts.contains(amount);
    } catch (e) {
      return false;
    }
  }

  Future<void> activateSubscription(String userId) async {
    final startDate = DateTime.now();

    // Create new subscription
    await _supabase.from('subscriptions').insert({
      'user_id': userId,
      'start_date': startDate.toIso8601String(),
      'is_active': true
    });

    // Update profile
    await _supabase
        .from('profiles')
        .update({ 'is_subscribed': true })
        .eq('id', userId);
  }
}