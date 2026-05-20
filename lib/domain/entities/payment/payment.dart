class PaymentEntity {
  final String transactionId;
  final String paymentUrl;
  final String qrisString;
  final String status;
  final String accessKey;

  PaymentEntity({
    required this.transactionId,
    required this.paymentUrl,
    required this.qrisString,
    required this.status,
    required this.accessKey,
  });
}