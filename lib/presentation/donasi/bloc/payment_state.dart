part of 'payment_cubit.dart';

abstract class PaymentState {}
class PaymentInitial extends PaymentState {}
class PaymentLoading extends PaymentState {}
class PaymentStatusChecking extends PaymentState {}

class PaymentSuccess extends PaymentState {
  final PaymentEntity payment;
  PaymentSuccess(this.payment);
}

class PaymentStatusChecked extends PaymentState {
  final String status;
  PaymentStatusChecked(this.status);
}

class PaymentFailure extends PaymentState {
  final String message;
  PaymentFailure(this.message);
}