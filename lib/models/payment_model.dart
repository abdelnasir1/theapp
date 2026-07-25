// models/payment_model.dart
class PaymentModel {
  final String id;
  final String userId;
  final String? receiptUrl;
  final double? amount;
  final String? transactionId;
  final String status;
  final DateTime? verifiedAt;
  final DateTime createdAt;

  PaymentModel({
    required this.id,
    required this.userId,
    this.receiptUrl,
    this.amount,
    this.transactionId,
    this.status = 'pending',
    this.verifiedAt,
    required this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      receiptUrl: json['receipt_url'],
      amount: json['amount'] != null
          ? double.parse(json['amount'].toString())
          : null,
      transactionId: json['transaction_id'],
      status: json['status'] ?? 'pending',
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'])
          : null,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'receipt_url': receiptUrl,
      'amount': amount,
      'transaction_id': transactionId,
      'status': status,
      'verified_at': verifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isVerified => status == 'valid';
  bool get isPending => status == 'pending';
  bool get isProcessing => status == 'processing';
}