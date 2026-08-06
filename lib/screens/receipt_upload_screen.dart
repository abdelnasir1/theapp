import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/constants.dart';
import 'dart:io';
import '../../providers/auth_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../services/payment_service.dart';

class ReceiptUploadScreen extends StatefulWidget {
  final String planName;
  final String price;

  const ReceiptUploadScreen({
    super.key,
    required this.planName,
    required this.price,
  });

  @override
  State<ReceiptUploadScreen> createState() => _ReceiptUploadScreenState();
}

class _ReceiptUploadScreenState extends State<ReceiptUploadScreen> {
  final PaymentService _paymentService = PaymentService();
  final ImagePicker _imagePicker = ImagePicker();
  File? _receiptImage;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('دفع اشتراك ${widget.planName}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'مبلغ الأشتراك: ${widget.price} جنيه',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Text(
              'طريقة الدفع',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoCard('1. حول مبلغ الإشتراك على حساب بنكك التالي'),
            const SizedBox(height: 12),
            _buildAccountCard(),
            const SizedBox(height: 16),
            _buildWarningCard(),
            const SizedBox(height: 24),
            _buildInfoCard('2. قم بتحميل الإيصال هنا'),
            const SizedBox(height: 16),
            _buildImagePicker(),
            const SizedBox(height: 24),
            _buildSubmitButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withAlpha(30)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }

  Widget _buildAccountCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withAlpha(100)),
      ),
      child: Column(
        children: [
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            onPressed: () {
              Clipboard.setData(const ClipboardData(text: '${AppConstants.accountnumber}'));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم النسخ')));
            },
          ),
          const SelectableText(
            '${AppConstants.accountnumber}',
            style: TextStyle(fontSize: 22, letterSpacing: 5, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('بأسم : معاذ خيال', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildWarningCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withAlpha(30)),
      ),
      child: Column(
        children: [
          const Text('تأكد من حفظ الإيصال عن طريق زر التحميل', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset('assets/images/download_image.jpg', height: 120, width: double.infinity, fit: BoxFit.cover),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[50],
      ),
      child: Column(
        children: [
          if (_receiptImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(_receiptImage!, height: 200, width: double.infinity, fit: BoxFit.cover),
            )
          else
            Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(_receiptImage != null ? 'تم رفع الإيصال بنجاح' : 'ارفع صورة الإيصال هنا', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _pickReceiptImage,
            icon: const Icon(Icons.photo_library),
            label: const Text('اختيار صورة'),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (_receiptImage != null && !_isProcessing) ? _processPayment : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isProcessing
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock),
                  SizedBox(width: 8),
                  Text('إرسال الإيصال', style: TextStyle(fontSize: 16)),
                ],
              ),
      ),
    );
  }

  Future<void> _pickReceiptImage() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery, maxWidth: 1800, maxHeight: 1800);
    if (image != null) setState(() => _receiptImage = File(image.path));
  }

  Future<void> _processPayment() async {
    if (_receiptImage == null) return;
    setState(() => _isProcessing = true);
    try {
      final authProvider = context.read<AuthProvider>();
      final subProvider = context.read<SubscriptionProvider>();
      final userId = authProvider.user?.id;
      if (userId == null) throw Exception('User not authenticated');

      final receiptUrl = await _paymentService.uploadReceipt(userId, _receiptImage!);
      final result = await subProvider.processReceipt(receiptUrl, userId, widget.planName);
      
      if (mounted) {
        if (result['success'] == true) {
          Navigator.pushReplacementNamed(context, '/home');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 5),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}
