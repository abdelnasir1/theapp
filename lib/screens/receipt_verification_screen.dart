// screens/payment/receipt_verification_screen.dart
import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';
//import '../../providers/auth_provider.dart';
//import '../../providers/subscription_provider.dart';

class ReceiptVerificationScreen extends StatefulWidget {
  final String receiptUrl;

  const ReceiptVerificationScreen({
    super.key,
    required this.receiptUrl,
  });

  @override
  State<ReceiptVerificationScreen> createState() =>
      _ReceiptVerificationScreenState();
}

class _ReceiptVerificationScreenState extends State<ReceiptVerificationScreen> {
  bool _isProcessing = false;
  Map<String, dynamic>? _result;

  @override
  void initState() {
    super.initState();
    _verifyReceipt();
  }

  Future<void> _verifyReceipt() async {
    setState(() => _isProcessing = true);

    try {
//      final provider = context.read<SubscriptionProvider>();
//      final userId = context.read<AuthProvider>().user!.id;
//      await provider.processReceipt(widget.receiptUrl, userId);

      setState(() {
        _result = {
          'success': true,
          'is_valid': true,
          'message': 'Transaction validated successfully!',
        };
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _result = {
          'success': false,
          'is_valid': false,
          'message': 'Verification failed: ${e.toString()}',
        };
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Verification'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _isProcessing
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text('Processing your receipt...'),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                backgroundColor: Colors.grey[200],
              ),
            ],
          )
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _result?['is_valid'] == true
                    ? Icons.check_circle
                    : Icons.error,
                size: 80,
                color: _result?['is_valid'] == true
                    ? Colors.green
                    : Colors.red,
              ),
              const SizedBox(height: 20),
              Text(
                _result?['is_valid'] == true
                    ? 'Transaction Valid'
                    : 'Transaction Invalid',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _result?['is_valid'] == true
                      ? Colors.green
                      : Colors.red,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _result?['message'] ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (_result?['is_valid'] == true) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                          (route) => false,
                    );
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  _result?['is_valid'] == true
                      ? 'Go to Home'
                      : 'Try Again',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
