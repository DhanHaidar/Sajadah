import 'package:sajadah/domain/repository/payment/payment.dart';
import 'package:sajadah/domain/entities/payment/payment.dart';
import 'package:sajadah/data/sources/payment/payment_remote_source.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteSource remoteSource;

  PaymentRepositoryImpl({required this.remoteSource});

  @override
  Future<PaymentEntity> createTransaction({
    required double amount,
    required String type,
    required String userEmail,
    required String userPhone,
  }) async {
    try {
      final responseData = await remoteSource.requestBtzPayTransaction(
        amount: amount, type: type, userEmail: userEmail, userPhone: userPhone,
      );
      
      if (responseData['success'] == true) {
        final data = responseData['data'];
        return PaymentEntity(
          transactionId: data['transactionId'] ?? '',
          paymentUrl: data['paymentUrl'] ?? '',
          qrisString: data['qrisString'] ?? '',
          status: data['status'] ?? 'pending',
          accessKey: data['accessKey'] ?? '', 
        );
      } else {
        throw Exception(responseData['message'] ?? 'Transaksi ditolak oleh server');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> checkStatus({required String transactionId, required String accessKey}) async {
    return await remoteSource.checkPaymentStatus(transactionId, accessKey);
  }
}