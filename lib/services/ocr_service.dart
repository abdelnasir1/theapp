// services/ocr_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class OCRService {
  // This is a placeholder for actual OCR service integration
  // You would integrate with Google Cloud Vision, AWS Textract, or Tesseract

  static Future<Map<String, dynamic>> processReceiptImage(
      File imageFile, {
        String? language = 'en',
      }) async {
    try {
      // Convert image to base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Call Supabase Edge Function for OCR
      // This is where you'd integrate with your chosen OCR service

      // Mock response for demonstration
      return {
        'success': true,
        'text': 'Sample receipt text',
        'confidence': 0.95,
        'extracted_data': {
          'amount': '19.99',
          'date': '2024-01-15',
          'merchant': 'Math Solutions Inc.',
          'transaction_id': 'TXN123456',
        },
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  static Map<String, dynamic> extractReceiptData(String ocrText) {
    final amountRegex = RegExp(r'\$(\d+\.?\d{0,2})');
    final dateRegex = RegExp(r'\d{2}/\d{2}/\d{4}|\d{4}-\d{2}-\d{2}');
    final transactionRegex = RegExp(r'Transaction\s*#?:?\s*(\w+)');

    return {
      'amount': amountRegex.firstMatch(ocrText)?.group(1) ?? '0.00',
      'date': dateRegex.firstMatch(ocrText)?.group(0) ?? DateTime.now().toIso8601String(),
      'transaction_id': transactionRegex.firstMatch(ocrText)?.group(1) ?? 'N/A',
    };
  }

  static bool validateReceiptData(Map<String, dynamic> extractedData) {
    // Validate that extracted data matches expected format
    final amount = double.tryParse(extractedData['amount']?.toString() ?? '0');
    final date = DateTime.tryParse(extractedData['date']?.toString() ?? '');

    return amount != null && amount > 0 && date != null;
  }
}