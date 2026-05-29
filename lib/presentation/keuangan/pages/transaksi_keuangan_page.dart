import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sajadah/common/widgets/app_drawer.dart';
import 'package:sajadah/common/widgets/profile_avatar.dart';
import 'package:sajadah/domain/entities/masjid/masjid_entity.dart';
import 'package:sajadah/domain/entities/payment/payment.dart';
import 'package:sajadah/domain/repository/auth/auth.dart';
import 'package:sajadah/presentation/donasi/bloc/payment_cubit.dart';
import 'package:sajadah/service_locator.dart';

class TransaksiKeuanganPage extends StatelessWidget {
  final MasjidEntity? masjid;

  const TransaksiKeuanganPage({super.key, this.masjid});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PaymentCubit(sl(), sl()),
      child: TransaksiKeuanganView(masjid: masjid),
    );
  }
}

class TransaksiKeuanganView extends StatefulWidget {
  final MasjidEntity? masjid;

  const TransaksiKeuanganView({super.key, this.masjid});

  @override
  State<TransaksiKeuanganView> createState() => _TransaksiKeuanganViewState();
}

class _TransaksiKeuanganViewState extends State<TransaksiKeuanganView> {
  static const List<double> _presetNominals = [
    5000,
    15000,
    25000,
    50000,
    100000,
    150000,
  ];

  static const List<String> _paymentMethods = [
    'BRI',
    'BCA',
    'Mandiri',
    'BNI',
    'Qris / Transfer Bank',
  ];

  final TextEditingController _customAmountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  double? _selectedNominal;
  String _selectedMethod = _paymentMethods.first;
  double? _pendingAmount;
  String? _pendingNote;
  PaymentEntity? _pendingPayment;
  DateTime? _expiryTime;
  Timer? _countdownTimer;
  bool _isSavingRecord = false;

  final ValueNotifier<String> _timeLeftNotifier = ValueNotifier<String>(
    '05:00',
  );

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _customAmountController.dispose();
    _noteController.dispose();
    _timeLeftNotifier.dispose();
    super.dispose();
  }

  void _selectNominal(double nominal) {
    setState(() {
      _selectedNominal = nominal;
      _customAmountController.clear();
    });
  }

  double _resolveAmount() {
    if (_customAmountController.text.trim().isNotEmpty) {
      final cleaned = _customAmountController.text.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
      return double.tryParse(cleaned) ?? 0;
    }

    return _selectedNominal ?? 0;
  }

  Future<Map<String, String>> _resolvePaymentContact() async {
    const fallbackEmail = 'user@example.com';
    const fallbackPhone = '081234567890';

    final snapshot = await sl<AuthRepository>().getCurrentUserStream().first;
    if (!snapshot.exists) {
      return const {'email': fallbackEmail, 'phone': fallbackPhone};
    }

    final data = snapshot.data() as Map<String, dynamic>?;
    final email = (data?['email'] as String?)?.trim();
    final phone =
        (data?['phone'] as String?)?.trim() ??
        (data?['phoneNumber'] as String?)?.trim() ??
        (data?['noHp'] as String?)?.trim() ??
        (data?['no_hp'] as String?)?.trim();

    return {
      'email': email != null && email.isNotEmpty ? email : fallbackEmail,
      'phone': phone != null && phone.isNotEmpty ? phone : fallbackPhone,
    };
  }

  void _startCountdown() {
    _expiryTime = DateTime.now().add(const Duration(minutes: 5));
    _countdownTimer?.cancel();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (_expiryTime != null && DateTime.now().isAfter(_expiryTime!)) {
        timer.cancel();
        _clearPendingTransaction(
          'Waktu pembayaran habis. Transaksi dibatalkan otomatis.',
        );
      } else {
        _timeLeftNotifier.value = _getFormattedTimeLeft();
        setState(() {});
      }
    });
  }

  String _getFormattedTimeLeft() {
    if (_expiryTime == null) return '00:00';
    final diff = _expiryTime!.difference(DateTime.now());
    if (diff.isNegative) return '00:00';
    final minutes = diff.inMinutes.toString().padLeft(2, '0');
    final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _clearPendingTransaction(String message, {bool isSuccess = false}) {
    _countdownTimer?.cancel();
    setState(() {
      _pendingPayment = null;
      _expiryTime = null;
      _pendingAmount = null;
      _pendingNote = null;
      _selectedNominal = null;
      _isSavingRecord = false;
    });

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    if (isSuccess) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Pembayaran berhasil', textAlign: TextAlign.center),
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

  Future<void> _submitPayment() async {
    final amount = _resolveAmount();
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih nominal terlebih dahulu')),
      );
      return;
    }

    final contact = await _resolvePaymentContact();
    _pendingAmount = amount;
    _pendingNote = _noteController.text.trim();

    if (!mounted) return;
    context.read<PaymentCubit>().processPayment(
      amount: amount,
      type: 'transaksi_keuangan',
      userEmail: contact['email'] ?? 'user@example.com',
      userPhone: contact['phone'] ?? '081234567890',
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
                      const Center(child: Text('Gagal memuat QR')),
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

  Future<void> _saveFinanceRecord(PaymentEntity payment) async {
    if (_isSavingRecord ||
        widget.masjid?.id == null ||
        _pendingAmount == null) {
      return;
    }

    _isSavingRecord = true;
    final amount = _pendingAmount!;
    final note = (_pendingNote?.trim().isNotEmpty ?? false)
        ? _pendingNote!.trim()
        : 'Pembayaran ${_selectedMethod.toLowerCase()}';

    await FirebaseFirestore.instance
        .collection('Masjid')
        .doc(widget.masjid!.id)
        .collection('TransaksiKeuangan')
        .add({
          'title': note,
          'keterangan': note,
          'amount': amount,
          'nominal': amount,
          'type': 'income',
          'jenis': 'pemasukan',
          'method': _selectedMethod,
          'paymentTransactionId': payment.transactionId,
          'accessKey': payment.accessKey,
          'status': 'sukses',
          'createdAt': FieldValue.serverTimestamp(),
          'masjidId': widget.masjid!.id,
        });
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp. ',
      decimalDigits: 0,
    ).format(amount);
  }

  Widget _buildNominalButton(double nominal) {
    final selected = _selectedNominal == nominal;
    return Expanded(
      child: OutlinedButton(
        onPressed: () => _selectNominal(nominal),
        style: OutlinedButton.styleFrom(
          backgroundColor: selected
              ? Colors.green.withOpacity(0.12)
              : const Color(0xFFF4F4F4),
          side: BorderSide(
            color: selected ? Colors.green : Colors.grey.shade400,
          ),
          foregroundColor: Colors.grey.shade800,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          _formatCurrency(nominal),
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildNominalRow(List<double> values) {
    return Row(
      children: [
        for (var index = 0; index < values.length; index++) ...[
          _buildNominalButton(values[index]),
          if (index != values.length - 1) const SizedBox(width: 10),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(masjid: widget.masjid),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        shadowColor: Colors.black12,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(widget.masjid?.title ?? 'Transaksi Keuangan'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_outlined),
          ),
          const ProfileAvatar(),
        ],
      ),
      body: BlocConsumer<PaymentCubit, PaymentState>(
        listener: (context, state) async {
          if (state is PaymentSuccess) {
            setState(() => _pendingPayment = state.payment);
            _startCountdown();
            _showQrisDialog(state.payment);
          } else if (state is PaymentStatusChecked) {
            if (state.status.toLowerCase() == 'sukses') {
              if (_pendingPayment != null) {
                try {
                  await _saveFinanceRecord(_pendingPayment!);
                  _clearPendingTransaction(
                    'Transaksi berhasil dibayar dan disimpan ke riwayat.',
                    isSuccess: true,
                  );
                } catch (e) {
                  _clearPendingTransaction(
                    'Pembayaran berhasil, tetapi gagal menyimpan riwayat transaksi: $e',
                  );
                }
              }
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
          final isButtonDisabled =
              state is PaymentLoading || _pendingPayment != null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7E7E7),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.14),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade400),
                          ),
                        ),
                        child: Text(
                          'Lakukan Pembayaran',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Pilih Nominal',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      _buildNominalRow(_presetNominals.take(3).toList()),
                      const SizedBox(height: 12),
                      _buildNominalRow(_presetNominals.skip(3).toList()),
                      const SizedBox(height: 22),
                      TextField(
                        controller: _customAmountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Jumlah Lainya',
                          hintText: 'Inputkan nominal (ex. 40.000)',
                          filled: true,
                          fillColor: const Color(0xFFF2F2F2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            setState(() => _selectedNominal = null);
                          }
                        },
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: _noteController,
                        decoration: InputDecoration(
                          labelText: 'Catatan (opsional)',
                          filled: true,
                          fillColor: const Color(0xFFF2F2F2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      DropdownButtonFormField<String>(
                        value: _selectedMethod,
                        items: _paymentMethods
                            .map(
                              (method) => DropdownMenuItem(
                                value: method,
                                child: Text(method),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _selectedMethod = value);
                        },
                        decoration: InputDecoration(
                          labelText: 'Metode Pembayaran',
                          filled: true,
                          fillColor: const Color(0xFFF2F2F2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: ElevatedButton(
                          onPressed: isButtonDisabled ? null : _submitPayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: state is PaymentLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Bayar'),
                        ),
                      ),
                    ],
                  ),
                ),
                if (state is PaymentLoading) ...[
                  const SizedBox(height: 16),
                  const Center(child: CircularProgressIndicator()),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
