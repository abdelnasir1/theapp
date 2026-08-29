import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> uploadReceipt(String userId, dynamic file) async {
    try {
      final fileName = '/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';

      await _supabase.storage .from('receipts') .upload(fileName, file);

      final publicUrl = _supabase.storage .from('receipts') .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload receipt: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> processPayment({
    required String userId,
    required String receiptUrl,
  }) async {
    try {
      // Create payment record
      final paymentResponse = await _supabase.from('payments').insert({
        'user_id': userId,
        'receipt_url': receiptUrl,
        'status': 'processing',
      }).select();

      if (paymentResponse.isEmpty) {
        throw Exception('Failed to create payment record');
      }

      return {
        'success': true,
        'payment_id': paymentResponse[0]['id'],
      };
    } catch (e) {
      throw Exception('Payment processing failed: ${e.toString()}');
    }
  }

}
