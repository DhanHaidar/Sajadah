import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class PaymentRemoteSource {
  Future<Map<String, dynamic>> requestBtzPayTransaction({
    required double amount,
    required String type,
    required String userEmail,
    required String userPhone,
  });
  
  Future<String> checkPaymentStatus(String transactionId, String accessKey);
}

class PaymentRemoteSourceImpl implements PaymentRemoteSource {
  final String baseUrl = 'https://web.btzpay.my.id/api/qris';
  final String apiKey = '8ce3d3a41bf7a392f3baf4ce87506db3cb4d9e74f4d508624bbc336a5e10d3e0'; 
  final String callbackUrl = 'https://catherina-sulfuryl-lochlan.ngrok-free.dev/webhook/payment/btzpay';

  @override
  Future<Map<String, dynamic>> requestBtzPayTransaction({
    required double amount,
    required String type,
    required String userEmail,
    required String userPhone,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/create'), // Menggunakan /create
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "apikey": apiKey,
        "amount": amount.toInt(),
        "fee": 0, 
        "notes": type, 
        "timeout": 300000, 
        "callback_url": callbackUrl,
        "return_url": "", 
        "metadata": {
          "orderId": "ORD-${DateTime.now().millisecondsSinceEpoch}",
          "productName": type
        },
        "customerInfo": {
          "name": "Hamba Allah", 
          "email": userEmail,
          "phone": userPhone
        },
        "accountNumber": "",
        "accountName": ""
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body); 
    } else {
      throw Exception('Gagal API BTZPay: ${response.body}');
    }
  }

  @override
  Future<String> checkPaymentStatus(String transactionId, String accessKey) async {
    final response = await http.get(
      Uri.parse('$baseUrl/transaction/$transactionId?key=$accessKey'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return data['data']['status'] ?? 'pending';
      }
    }
    throw Exception('Gagal mengecek status transaksi');
  }
}