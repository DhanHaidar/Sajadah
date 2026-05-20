import '../../repository/payment/payment.dart';

class CheckPaymentStatusUseCase {
  final PaymentRepository repository;

  CheckPaymentStatusUseCase(this.repository);

  Future<String> call({required String transactionId, required String accessKey}) async {
    return await repository.checkStatus(transactionId: transactionId, accessKey: accessKey);
  }
}