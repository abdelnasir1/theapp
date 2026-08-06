// services/supabase_service.dart
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
      return [];
    }
  }

  /// Submits the receipt to the server. 
  /// The server (Edge Function/Database) is responsible for OCR, 
  /// validation, updating payment status, and activating the subscription.
  Future<Map<String, dynamic>> processAndValidateReceipt(
    String receiptUrl,
    String userId,
    String planName,
  ) async {
    try {
      // 1. Create the payment record with 'processing' status
      await _supabase.from('payments').insert({
        'user_id': userId,
        'receipt_url': receiptUrl,
        'status': 'processing',
        'plan_type': planName
      });

      // 2. Notify the server to start verification
      // We invoke the function and let it handle all database updates (payments and subscriptions)
    //  await _supabase.functions.invoke(
     //   'process-receipt-ocr',
      //  body: {
       //   'receipt_url': receiptUrl,
        //  'user_id': userId,
         // 'plan_name': planName,
       // },
    //  );

      return {
        'success': true,
        'message': 'تم إرسال الإيصال بنجاح. سنقوم بالتحقق منه وتفعيل اشتراكك قريباً.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'فشل إرسال الإيصال: ${e.toString()}',
      };
    }
  }

  Future<void> submitFeedback({
    required String? userId,
    required String message,
    Map<String, dynamic>? metadata,
  }) async {
    await _supabase.from('feedback').insert({
      'user_id': userId,
      'message': message,
      'metadata': metadata ?? {},
    });
  }
}
