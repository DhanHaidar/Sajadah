import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sajadah/domain/entities/donasi/donasi_entity.dart';
import 'package:sajadah/domain/entities/payment/payment.dart';
import 'package:sajadah/domain/usecases/donasi/update_donasi_collected_amount.dart';
import 'package:sajadah/presentation/donasi/bloc/payment_cubit.dart';
import 'package:sajadah/service_locator.dart';

class DonasiPage extends StatelessWidget {
  final String? masjidId;
  final DonasiEntity campaign;
  const DonasiPage({super.key, required this.campaign, this.masjidId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PaymentCubit(sl(), sl()), // Inject 2 Usecase
      child: DonasiView(masjidId: masjidId, campaign: campaign),
    );
  }
}

class DonasiView extends StatefulWidget {
  final String? masjidId;
  final DonasiEntity campaign;
  const DonasiView({super.key, required this.campaign, this.masjidId});

  @override
  State<DonasiView> createState() => _DonasiViewState();
}

class _DonasiViewState extends State<DonasiView> {
  final List<double> presetNominals = [
    5000,
    15000,
    25000,
    50000,
    100000,
    150000,
  ];
  double? selectedNominal;
  double _collectedAmount = 0;
  double? _pendingDonationAmount;
  bool _isRecordingDonation = false;

  final TextEditingController _customAmountController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String selectedMethod = 'Qris / Transfer Bank (BTZPay)';

  PaymentEntity? _pendingPayment;
  DateTime? _expiryTime;
  Timer? _countdownTimer;
  final ValueNotifier<String> _timeLeftNotifier = ValueNotifier<String>(
    "05:00",
  );

  @override
  void initState() {
    super.initState();
    _collectedAmount = widget.campaign.collectedAmount;
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _customAmountController.dispose();
    _phoneController.dispose();
    _timeLeftNotifier.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _expiryTime = DateTime.now().add(const Duration(minutes: 5));
    _countdownTimer?.cancel();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_expiryTime != null && DateTime.now().isAfter(_expiryTime!)) {
        timer.cancel();
        _clearPendingTransaction(
          "Waktu pembayaran habis. Transaksi dibatalkan otomatis.",
        );
      } else {
        _timeLeftNotifier.value = _getFormattedTimeLeft();
        setState(() {});
      }
    });
  }

  String _getFormattedTimeLeft() {
    if (_expiryTime == null) return "00:00";
    final diff = _expiryTime!.difference(DateTime.now());
    if (diff.isNegative) return "00:00";
    final minutes = diff.inMinutes.toString().padLeft(2, '0');
    final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  void _clearPendingTransaction(String message, {bool isSuccess = false}) {
    _countdownTimer?.cancel();
    setState(() {
      _pendingPayment = null;
      _expiryTime = null;
      _pendingDonationAmount = null;
      _isRecordingDonation = false;
    });

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    if (isSuccess) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Alhamdulillah!', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  void _onNominalSelected(double nominal) {
    setState(() {
      selectedNominal = nominal;
      _customAmountController.clear();
    });
  }

  void _submitDonasi() {
    double amount = 0;
    if (_customAmountController.text.isNotEmpty) {
      amount =
          double.tryParse(_customAmountController.text.replaceAll('.', '')) ??
          0;
    } else if (selectedNominal != null) {
      amount = selectedNominal!;
    }

    if (amount <= 0) return;
    String phone = _phoneController.text.trim();
    if (phone.isEmpty) return;

    _pendingDonationAmount = amount;
    _isRecordingDonation = false;

    context.read<PaymentCubit>().processPayment(
      amount: amount,
      type: 'donasi',
      userEmail: 'user@example.com',
      userPhone: phone,
    );
  }

  void _showQrisDialog(PaymentEntity payment) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Scan QRIS',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValueListenableBuilder<String>(
                valueListenable: _timeLeftNotifier,
                builder: (context, value, child) {
                  return Text(
                    'Sisa Waktu: $value',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontSize: 18,
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              Text(
                'TRX ID: ${payment.transactionId}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                height: 200,
                child: QrImageView(
                  data: payment.qrisString,
                  version: QrVersions.auto,
                  size: 200.0,
                  errorStateBuilder: (cxt, err) =>
                      const Center(child: Text("Gagal memuat QR")),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Pastikan nominal yang dibayar sesuai hingga digit terakhir (kode unik).',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.orange),
              ),
            ],
          ),
        ),
        actions: [
          // TOMBOL CEK STATUS DI DALAM POP-UP
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Cek Pembayaran'),
            onPressed: () {
              context.read<PaymentCubit>().checkPaymentStatus(
                payment.transactionId,
                payment.accessKey,
              );
            },
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Future<void> _recordDonationAmount(double amount) async {
    if (_isRecordingDonation) return;
    final masjidId = widget.masjidId;
    final donasiId = widget.campaign.id;

    if (masjidId == null || donasiId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menyimpan nominal donasi: data tidak lengkap'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _isRecordingDonation = true;
    final result = await sl<UpdateDonasiCollectedAmountUseCase>().call(
      masjidId: masjidId,
      donasiId: donasiId,
      amount: amount,
    );

    result.fold(
      (error) {
        _isRecordingDonation = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan nominal donasi: $error'),
            backgroundColor: Colors.red,
          ),
        );
      },
      (_) {
        if (!mounted) return;
        setState(() {
          _collectedAmount += amount;
          _pendingDonationAmount = null;
          _isRecordingDonation = false;
        });
      },
    );
  }

  String _formatCurrency(double amount) {
    String result = amount.toInt().toString();
    result = result.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return result;
  }

  int _calculateDaysLeft(DateTime endDate) {
    final diff = endDate.difference(DateTime.now());
    if (diff.isNegative) return 0;
    return diff.inDays;
  }

  Widget _buildDonasiImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        height: 160,
        color: Colors.grey.shade300,
        child: Icon(Icons.image, color: Colors.grey.shade600),
      );
    }

    return Image.network(
      imageUrl,
      height: 160,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 160,
          color: Colors.grey.shade300,
          child: Icon(Icons.broken_image, color: Colors.grey.shade600),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donasi', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: BlocConsumer<PaymentCubit, PaymentState>(
        listener: (context, state) async {
          if (state is PaymentSuccess) {
            setState(() => _pendingPayment = state.payment);
            _startCountdown();
            _showQrisDialog(state.payment);
          } else if (state is PaymentStatusChecked) {
            // JIKA CEK STATUS BERHASIL "SUKSES"
            if (state.status.toLowerCase() == 'sukses') {
              final amount = _pendingDonationAmount;
              if (amount != null && amount > 0) {
                await _recordDonationAmount(amount);
              }
              _clearPendingTransaction(
                "Terima kasih atas donasinya! Transaksi telah berhasil.",
                isSuccess: true,
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Status pembayaran saat ini: ${state.status.toUpperCase()}',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          } else if (state is PaymentFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final bool isButtonDisabled =
              (state is PaymentLoading) || (_pendingPayment != null);
          final campaign = widget.campaign;
          final daysLeft = _calculateDaysLeft(campaign.endDate);
          final target = campaign.targetAmount;
          final collected = _collectedAmount;
          double progress = 0;
          if (target > 0) {
            progress = collected / target;
          }
          if (progress.isNaN || progress.isInfinite) {
            progress = 0;
          }
          progress = progress.clamp(0, 1);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDonasiImage(campaign.imageUrl),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              campaign.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              campaign.description,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Sisa waktu donasi : $daysLeft hari',
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      minHeight: 8,
                                      value: progress,
                                      backgroundColor: Colors.grey.shade300,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                            Colors.green,
                                          ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${_formatCurrency(collected)}/${_formatCurrency(target)}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (_pendingPayment != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.pending_actions, color: Colors.orange),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Menunggu Pembayaran',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                'Kedaluwarsa dalam: ${_timeLeftNotifier.value}',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(90, 30),
                              ),
                              onPressed: () =>
                                  _showQrisDialog(_pendingPayment!),
                              child: const Text('Lihat QRIS'),
                            ),
                            const SizedBox(height: 4),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                minimumSize: const Size(90, 30),
                              ),
                              onPressed: () => _clearPendingTransaction(
                                "Transaksi dibatalkan manual.",
                              ),
                              child: const Text('Batal'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Donasi Sekarang Juga',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 2.2,
                            ),
                        itemCount: presetNominals.length,
                        itemBuilder: (context, index) {
                          final nominal = presetNominals[index];
                          final isSelected = selectedNominal == nominal;
                          return OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: isSelected
                                  ? Theme.of(
                                      context,
                                    ).primaryColor.withOpacity(0.1)
                                  : Colors.transparent,
                              side: BorderSide(
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey.shade300,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => _onNominalSelected(nominal),
                            child: Text(
                              'Rp. ${nominal.toInt() ~/ 1000}.000',
                              style: TextStyle(
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.black87,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),
                      const Text(
                        'Jumlah Lain',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _customAmountController,
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          if (val.isNotEmpty) {
                            setState(() => selectedNominal = null);
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'ex. 40.000',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Text(
                        'Nomor Whatsapp / Telepon',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'ex. 08123456789',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Text(
                        'Metode Pembayaran',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: selectedMethod,
                            items: <String>['Qris / Transfer Bank (BTZPay)']
                                .map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                })
                                .toList(),
                            onChanged: (_) {},
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isButtonDisabled ? null : _submitDonasi,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isButtonDisabled
                                ? Colors.grey
                                : Theme.of(context).primaryColor,
                          ),
                          child:
                              state is PaymentLoading ||
                                  state is PaymentStatusChecking
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Donasi',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
