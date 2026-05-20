import '../../repository/payment/payment.dart';
import '../../entities/payment/payment.dart';

class CreatePaymentUseCase {
  final PaymentRepository repository;

  CreatePaymentUseCase(this.repository);

  Future<PaymentEntity> call({
    required double amount,
    required String type,
    required String userEmail,
    required String userPhone, // Tambahan untuk No Telp
  }) async {
    return await repository.createTransaction(
      amount: amount,
      type: type,
      userEmail: userEmail,
      userPhone: userPhone, // Teruskan ke Repository
    );
  }
}