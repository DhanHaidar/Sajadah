import '../../entities/payment/payment.dart';

abstract class PaymentRepository {
  Future<PaymentEntity> createTransaction({
    required double amount,
    required String type,
    required String userEmail,
    required String userPhone,
  });

  // Fungsi untuk mengecek status transaksi
  Future<String> checkStatus({
    required String transactionId,
    required String accessKey,
  });
}