import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sajadah/domain/entities/payment/payment.dart';
import 'package:sajadah/domain/usecases/payment/create_payment.dart';
import 'package:sajadah/domain/usecases/payment/check_payment_status.dart';

part 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final CreatePaymentUseCase _createPaymentUseCase;
  final CheckPaymentStatusUseCase _checkPaymentStatusUseCase;

  PaymentCubit(this._createPaymentUseCase, this._checkPaymentStatusUseCase) : super(PaymentInitial());

  Future<void> processPayment({
    required double amount,
    required String type,
    required String userEmail,
    required String userPhone,
  }) async {
    emit(PaymentLoading());
    try {
      final paymentData = await _createPaymentUseCase(
        amount: amount, type: type, userEmail: userEmail, userPhone: userPhone,
      );
      emit(PaymentSuccess(paymentData));
    } catch (e) {
      emit(PaymentFailure(e.toString()));
    }
  }

  Future<void> checkPaymentStatus(String trxId, String accessKey) async {
    emit(PaymentStatusChecking());
    try {
      final status = await _checkPaymentStatusUseCase(transactionId: trxId, accessKey: accessKey);
      emit(PaymentStatusChecked(status));
    } catch (e) {
      emit(PaymentFailure(e.toString()));
    }
  }
}