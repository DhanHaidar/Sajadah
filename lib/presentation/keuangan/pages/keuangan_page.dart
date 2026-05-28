import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sajadah/common/widgets/app_drawer.dart';
import 'package:sajadah/domain/entities/masjid/masjid_entity.dart';
import 'package:sajadah/domain/repository/auth/auth.dart';
import 'package:sajadah/presentation/keuangan/pages/transaksi_keuangan_page.dart';
import 'package:sajadah/service_locator.dart';

class KeuanganPage extends StatefulWidget {
  final MasjidEntity? masjid;

  const KeuanganPage({super.key, this.masjid});

  @override
  State<KeuanganPage> createState() => _KeuanganPageState();
}

class _KeuanganPageState extends State<KeuanganPage> {
  static const String _collectionName = 'TransaksiKeuangan';

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _historySectionKey = GlobalKey();

  late final String? _masjidId;
  late final Stream<List<_FinanceRecord>> _recordsStream;

  _FinanceFilter _selectedFilter = _FinanceFilter.all;

  @override
  void initState() {
    super.initState();
    _masjidId = widget.masjid?.id;
    _recordsStream = _createRecordsStream();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Stream<List<_FinanceRecord>> _createRecordsStream() {
    if (_masjidId?.isEmpty ?? true) {
      return const Stream<List<_FinanceRecord>>.empty();
    }

    return FirebaseFirestore.instance
        .collection('Masjid')
        .doc(_masjidId)
        .collection(_collectionName)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => _FinanceRecord.fromFirestore(doc))
                  .toList()
                ..sort((left, right) => right.date.compareTo(left.date)),
        );
  }

  void _scrollToHistory() {
    final sectionContext = _historySectionKey.currentContext;
    if (sectionContext == null) return;
    Scrollable.ensureVisible(
      sectionContext,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      alignment: 0.05,
    );
  }

  void _showManageSheet(_FinanceSummary summary, List<_FinanceRecord> records) {
    final pageContext = context;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kelola Keuangan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  label: 'Pemasukan bulan ini',
                  value: _formatCurrency(summary.incomeThisMonth),
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  label: 'Pengeluaran bulan ini',
                  value: _formatCurrency(summary.expenseThisMonth),
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  label: 'Saldo bersih',
                  value: _formatCurrency(summary.netBalance),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          Navigator.of(pageContext).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  TransaksiKeuanganPage(masjid: widget.masjid),
                            ),
                          );
                        },
                        icon: const Icon(Icons.payments_outlined),
                        label: const Text('Tambah transaksi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          _exportCsv(records);
                        },
                        child: const Text('Unduh CSV'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _exportCsv(List<_FinanceRecord> records) async {
    if (records.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Belum ada transaksi untuk diunduh')),
      );
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln('tanggal,jenis,keterangan,nominal');
    for (final record in records) {
      buffer.writeln(
        '${_formatIsoDate(record.date)},${record.type.label},${_escapeCsv(record.title)},${record.amount.toStringAsFixed(0)}',
      );
    }

    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('CSV ringkasan transaksi disalin ke clipboard'),
      ),
    );
  }

  String _escapeCsv(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  String _formatIsoDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_monthNames[date.month - 1]} ${date.year}';
  }

  String _formatCurrency(num value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp. ',
      decimalDigits: 0,
    ).format(value);
  }

  List<_FinanceRecord> _applyFilter(List<_FinanceRecord> records) {
    switch (_selectedFilter) {
      case _FinanceFilter.income:
        return records
            .where((record) => record.type == _FinanceType.income)
            .toList();
      case _FinanceFilter.expense:
        return records
            .where((record) => record.type == _FinanceType.expense)
            .toList();
      case _FinanceFilter.all:
        return records;
    }
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
        title: Text(widget.masjid?.title ?? 'Keuangan Masjid'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_outlined),
          ),
          StreamBuilder<DocumentSnapshot>(
            stream: sl<AuthRepository>().getCurrentUserStream(),
            builder: (context, snapshot) {
              String initial = 'B';
              if (snapshot.hasData && snapshot.data!.exists) {
                final data = snapshot.data!.data() as Map<String, dynamic>?;
                final name = data?['name'] as String?;
                if (name != null && name.isNotEmpty) {
                  initial = name[0].toUpperCase();
                }
              }

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.green,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _masjidId == null
          ? const _EmptyFinanceState()
          : StreamBuilder<List<_FinanceRecord>>(
              stream: _recordsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final records = snapshot.data ?? const <_FinanceRecord>[];
                final summary = _FinanceSummary.from(records);
                final visibleRecords = _applyFilter(records);

                return SafeArea(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Keuangan Masjid',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () =>
                                  _showManageSheet(summary, records),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                minimumSize: const Size(0, 36),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: const Text('Kelola'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _scrollToHistory,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                minimumSize: const Size(0, 36),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: const Text('Transaksi'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _SummaryCard(
                          color: const Color(0xFF59F36A),
                          title: 'Total Pemasukan',
                          amount: _formatCurrency(summary.incomeThisMonth),
                          subtitle: 'Bulan ini',
                        ),
                        const SizedBox(height: 10),
                        _SummaryCard(
                          color: const Color(0xFFFF4D6D),
                          title: 'Total Pengeluaran',
                          amount: _formatCurrency(summary.expenseThisMonth),
                          subtitle: 'Bulan ini',
                        ),
                        const SizedBox(height: 10),
                        _SummaryCard(
                          color: const Color(0xFF5B8FF9),
                          title: 'Saldo Bersih',
                          amount: _formatCurrency(summary.netBalance),
                          subtitle: summary.netBalance >= 0
                              ? 'Surplus'
                              : 'Defisit',
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Ringkasan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _ChartCard(summary: summary),
                        const SizedBox(height: 20),
                        const Text(
                          'Riwayat Transaksi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _FilterBar(
                          selectedFilter: _selectedFilter,
                          onChanged: (filter) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Menampilkan ${visibleRecords.length} dari ${records.length} transaksi',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => _exportCsv(visibleRecords),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                minimumSize: const Size(0, 34),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: const Text('Unduh'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          key: _historySectionKey,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        'Tanggal',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        'Keterangan',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        'Nominal',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (visibleRecords.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Text(
                                    records.isEmpty
                                        ? 'Belum ada transaksi keuangan'
                                        : 'Tidak ada transaksi yang sesuai filter',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                )
                              else
                                ListView.separated(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: visibleRecords.length,
                                  separatorBuilder: (_, __) => Divider(
                                    height: 1,
                                    color: Colors.grey.shade300,
                                  ),
                                  itemBuilder: (context, index) {
                                    final record = visibleRecords[index];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              _formatDate(record.date),
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              record.title,
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              _formatCurrency(record.amount),
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    record.type ==
                                                        _FinanceType.income
                                                    ? Colors.green.shade700
                                                    : Colors.red.shade700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _EmptyFinanceState extends StatelessWidget {
  const _EmptyFinanceState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Masjid belum dipilih.\nPilih masjid terlebih dahulu untuk melihat data keuangan.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final Color color;
  final String title;
  final String amount;
  final String subtitle;

  const _SummaryCard({
    required this.color,
    required this.title,
    required this.amount,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            amount,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final _FinanceSummary summary;

  const _ChartCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Grafik Keuangan Bulanan',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Perbandingan pemasukan & pengeluaran',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Icon(Icons.bar_chart_outlined, color: Colors.grey.shade400),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(height: 240, child: _FinanceChart(summary: summary)),
        ],
      ),
    );
  }
}

class _FinanceChart extends StatelessWidget {
  final _FinanceSummary summary;

  const _FinanceChart({required this.summary});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxValue = summary.monthlyBuckets
            .map((bucket) => math.max(bucket.income, bucket.expense))
            .fold<double>(0, math.max);
        final axisMax = maxValue <= 0 ? 1.0 : maxValue;
        final axisTicks = _buildAxisTicks(axisMax);
        final chartHeight = math.max(160.0, constraints.maxHeight);
        const axisWidth = 44.0;
        const bottomLabelHeight = 36.0;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
              width: axisWidth,
              height: chartHeight - bottomLabelHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: axisTicks.reversed
                    .map(
                      (value) => Text(
                        _axisLabel(value),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                children: [
                  SizedBox(
                    height: chartHeight - bottomLabelHeight,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(
                                5,
                                (index) => Divider(
                                  height: 1,
                                  color: Colors.grey.shade200,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _FinanceLineChartPainter(
                              points: summary.monthlyBuckets
                                  .map(
                                    (bucket) => _ChartSeriesPoint(
                                      income: bucket.income,
                                      expense: bucket.expense,
                                    ),
                                  )
                                  .toList(),
                              maxValue: axisMax,
                              incomeColor: const Color(0xFF16A34A),
                              expenseColor: const Color(0xFFDC2626),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: bottomLabelHeight,
                    child: Row(
                      children: summary.monthlyBuckets.map((bucket) {
                        return Expanded(
                          child: Center(
                            child: Text(
                              bucket.label,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  List<double> _buildAxisTicks(double maxValue) {
    if (maxValue <= 0) return [0, 1];

    const fractionPoints = [0.25, 0.5, 0.75, 1.0];
    return [
      0,
      ...fractionPoints.map((fraction) {
        final rawTick = maxValue * fraction;
        if (fraction == 1.0) return rawTick;

        final magnitude = math.pow(10, (math.log(rawTick) / math.ln10).floor());
        final roundedDown = (rawTick / magnitude).floor() * magnitude;
        return roundedDown <= 0 ? rawTick : roundedDown.toDouble();
      }),
    ];
  }

  String _axisLabel(double value) {
    if (value <= 0) return '0';
    return NumberFormat.decimalPattern('id_ID').format(value.floor());
  }
}

class _ChartSeriesPoint {
  final double income;
  final double expense;

  const _ChartSeriesPoint({required this.income, required this.expense});
}

class _FinanceLineChartPainter extends CustomPainter {
  final List<_ChartSeriesPoint> points;
  final double maxValue;
  final Color incomeColor;
  final Color expenseColor;

  _FinanceLineChartPainter({
    required this.points,
    required this.maxValue,
    required this.incomeColor,
    required this.expenseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    _drawGrid(canvas, size);
    _drawSeries(
      canvas,
      _buildOffsetPoints(points.map((p) => p.income).toList(), size),
      size,
      incomeColor,
    );
    _drawSeries(
      canvas,
      _buildOffsetPoints(points.map((p) => p.expense).toList(), size),
      size,
      expenseColor,
    );
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1;

    const rows = 4;
    final stepY = size.height / rows;
    for (var i = 1; i < rows; i++) {
      final y = stepY * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final baselinePaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.2;
    canvas.drawLine(
      Offset(0, size.height - 1),
      Offset(size.width, size.height - 1),
      baselinePaint,
    );
  }

  void _drawSeries(
    Canvas canvas,
    List<Offset> seriesPoints,
    Size size,
    Color color,
  ) {
    if (seriesPoints.isEmpty) return;

    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final path = Path()..moveTo(seriesPoints.first.dx, seriesPoints.first.dy);
    for (var i = 1; i < seriesPoints.length; i++) {
      final previous = seriesPoints[i - 1];
      final current = seriesPoints[i];
      final midX = (previous.dx + current.dx) / 2;
      path.cubicTo(midX, previous.dy, midX, current.dy, current.dx, current.dy);
    }
    canvas.drawPath(path, linePaint);

    final fillPath = Path.from(path)
      ..lineTo(seriesPoints.last.dx, size.height)
      ..lineTo(seriesPoints.first.dx, size.height)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..color = color.withOpacity(0.12)
        ..style = PaintingStyle.fill,
    );

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (final point in seriesPoints) {
      canvas.drawCircle(point, 5.5, borderPaint);
      canvas.drawCircle(point, 3.5, dotPaint);
    }
  }

  List<Offset> _buildOffsetPoints(List<double> values, Size size) {
    if (values.isEmpty) return [];

    final safeMax = maxValue <= 0 ? 1.0 : maxValue;
    final spacing = values.length == 1 ? 0.0 : size.width / (values.length - 1);

    return List.generate(values.length, (index) {
      final ratio = (values[index] / safeMax).clamp(0.0, 1.0);
      final x = spacing * index;
      final y = size.height - (size.height * ratio);
      return Offset(x, y);
    });
  }

  @override
  bool shouldRepaint(covariant _FinanceLineChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.incomeColor != incomeColor ||
        oldDelegate.expenseColor != expenseColor;
  }
}

class _FilterBar extends StatelessWidget {
  final _FinanceFilter selectedFilter;
  final ValueChanged<_FinanceFilter> onChanged;

  const _FilterBar({required this.selectedFilter, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FilterPill(
          label: 'Semua',
          selected: selectedFilter == _FinanceFilter.all,
          onTap: () => onChanged(_FinanceFilter.all),
        ),
        const SizedBox(width: 6),
        _FilterPill(
          label: 'Pemasukan',
          selected: selectedFilter == _FinanceFilter.income,
          onTap: () => onChanged(_FinanceFilter.income),
        ),
        const SizedBox(width: 6),
        _FilterPill(
          label: 'Pengeluaran',
          selected: selectedFilter == _FinanceFilter.expense,
          onTap: () => onChanged(_FinanceFilter.expense),
        ),
      ],
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.green : Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.green, width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.green,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

enum _FinanceFilter { all, income, expense }

enum _FinanceType { income, expense }

class _FinanceRecord {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final _FinanceType type;

  const _FinanceRecord({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
  });

  factory _FinanceRecord.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final rawAmount = data['amount'] ?? data['nominal'] ?? data['jumlah'] ?? 0;
    final rawTitle =
        data['title'] ??
        data['keterangan'] ??
        data['deskripsi'] ??
        data['note'] ??
        'Transaksi';
    final rawDate =
        data['createdAt'] ?? data['tanggal'] ?? data['date'] ?? data['waktu'];
    final rawType =
        data['type'] ??
        data['jenis'] ??
        data['tipe'] ??
        data['transactionType'];

    return _FinanceRecord(
      id: doc.id,
      title: rawTitle.toString(),
      amount: _parseAmount(rawAmount),
      date: _parseDate(rawDate) ?? DateTime.now(),
      type: _parseType(rawType, rawAmount),
    );
  }

  static double _parseAmount(dynamic value) {
    if (value is num) return value.toDouble();
    final cleaned = value.toString().replaceAll(RegExp(r'[^0-9\-]'), '');
    return double.tryParse(cleaned) ?? 0;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static _FinanceType _parseType(dynamic rawType, dynamic rawAmount) {
    final text = rawType?.toString().toLowerCase() ?? '';
    if (text.contains('keluar') ||
        text.contains('expense') ||
        text.contains('pengeluaran') ||
        text.contains('debit')) {
      return _FinanceType.expense;
    }
    if (text.contains('masuk') ||
        text.contains('income') ||
        text.contains('pemasukan') ||
        text.contains('credit')) {
      return _FinanceType.income;
    }

    final amount = _parseAmount(rawAmount);
    return amount < 0 ? _FinanceType.expense : _FinanceType.income;
  }
}

class _MonthlyBucket {
  final String label;
  final DateTime start;
  final DateTime end;

  double income;
  double expense;

  _MonthlyBucket({
    required this.label,
    required this.start,
    required this.end,
    this.income = 0.0,
    this.expense = 0.0,
  });
}

class _FinanceSummary {
  final double incomeThisMonth;
  final double expenseThisMonth;
  final double netBalance;
  final List<_MonthlyBucket> monthlyBuckets;

  const _FinanceSummary({
    required this.incomeThisMonth,
    required this.expenseThisMonth,
    required this.netBalance,
    required this.monthlyBuckets,
  });

  factory _FinanceSummary.from(List<_FinanceRecord> records) {
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);
    final nextMonthStart = DateTime(now.year, now.month + 1, 1);

    double incomeThisMonth = 0;
    double expenseThisMonth = 0;

    final monthlyBuckets = List.generate(6, (index) {
      final monthOffset = index - 5;
      final month = DateTime(now.year, now.month + monthOffset, 1);
      final nextMonth = DateTime(month.year, month.month + 1, 1);
      return _MonthlyBucket(
        label: _monthShortNames[month.month - 1],
        start: month,
        end: nextMonth,
      );
    });

    for (final record in records) {
      if (!record.date.isBefore(currentMonthStart) &&
          record.date.isBefore(nextMonthStart)) {
        if (record.type == _FinanceType.income) {
          incomeThisMonth += record.amount;
        } else {
          expenseThisMonth += record.amount;
        }
      }

      for (final bucket in monthlyBuckets) {
        if (!record.date.isBefore(bucket.start) &&
            record.date.isBefore(bucket.end)) {
          if (record.type == _FinanceType.income) {
            bucket.income += record.amount;
          } else {
            bucket.expense += record.amount;
          }
          break;
        }
      }
    }

    return _FinanceSummary(
      incomeThisMonth: incomeThisMonth,
      expenseThisMonth: expenseThisMonth,
      netBalance: incomeThisMonth - expenseThisMonth,
      monthlyBuckets: monthlyBuckets,
    );
  }
}

const List<String> _monthNames = <String>[
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

const List<String> _monthShortNames = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

extension on _FinanceType {
  String get label => this == _FinanceType.income ? 'pemasukan' : 'pengeluaran';
}
