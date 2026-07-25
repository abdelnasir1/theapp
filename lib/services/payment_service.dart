// services/payment_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> uploadReceipt(String userId, dynamic file) async {
    try {
      final fileName = 'receipts/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';

      final response = await _supabase.storage
          .from('receipts')
          .upload(fileName, file);

      final publicUrl = _supabase.storage
          .from('receipts')
          .getPublicUrl(response);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload receipt: ${e.toString()}');
    }
  }
  Future<int>GetPrice() async {
    throw Exception("something");
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

      // Call edge function for OCR processing
      final ocrResponse = await _supabase.functions.invoke(
        'process-receipt-ocr',
        body: {
          'receipt_url': receiptUrl,
          'user_id': userId,
        },
      );

      return {
        'success': true,
        'payment_id': paymentResponse[0]['id'],
        'ocr_data': ocrResponse.data,
      };
    } catch (e) {
      throw Exception('Payment processing failed: ${e.toString()}');
    }
  }

  Future<bool> verifyPayment(String paymentId) async {
    try {
      final response = await _supabase
          .from('payments')
          .select('status')
          .eq('id', paymentId)
          .single();

      return response['status'] == 'valid';
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getPaymentHistory(String userId) async {
    try {
      final response = await _supabase
          .from('payments')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response;
    } catch (e) {
      return [];
    }
  }
}
