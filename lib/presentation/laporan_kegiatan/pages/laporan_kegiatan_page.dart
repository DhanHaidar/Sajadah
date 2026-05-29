import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sajadah/common/auth/role_helper.dart';
import 'package:sajadah/common/widgets/app_drawer.dart';
import 'package:sajadah/domain/entities/event/event.dart';
import 'package:sajadah/data/models/Event/event.dart';
import 'package:sajadah/domain/entities/masjid/masjid_entity.dart';
import 'package:sajadah/domain/repository/auth/auth.dart';
import 'package:sajadah/presentation/events/pages/event_detail_page.dart';
import 'package:sajadah/presentation/laporan_kegiatan/pages/buat_laporan_kegiatan_page.dart';
import 'package:sajadah/presentation/profile/profile_page.dart';
import 'package:sajadah/service_locator.dart';

enum _ReportFilter { all, withImage, withoutImage }

class LaporanKegiatanPage extends StatefulWidget {
  final MasjidEntity? masjid;

  const LaporanKegiatanPage({super.key, this.masjid});

  @override
  State<LaporanKegiatanPage> createState() => _LaporanKegiatanPageState();
}

class _LaporanKegiatanPageState extends State<LaporanKegiatanPage> {
  static const String _collectionName = 'Laporan';

  final TextEditingController _searchController = TextEditingController();

  late final Stream<List<EventEntity>> _reportsStream;

  String _searchQuery = '';
  _ReportFilter _filter = _ReportFilter.all;

  @override
  void initState() {
    super.initState();
    _reportsStream = _createReportsStream();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Stream<List<EventEntity>> _createReportsStream() {
    final masjidId = widget.masjid?.id;

    final query = masjidId == null
        ? FirebaseFirestore.instance
              .collectionGroup(_collectionName)
              .orderBy('waktu', descending: true)
        : FirebaseFirestore.instance
              .collection('Masjid')
              .doc(masjidId)
              .collection(_collectionName)
              .orderBy('waktu', descending: true);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final derivedMasjidId = doc.reference.parent.parent?.id;
        final model = EventModel.fromJson(
          data,
          docId: doc.id,
          masjidId: derivedMasjidId,
        );
        return model.toEntity();
      }).toList();
    });
  }

  Future<void> _openCreatePage() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final role = await RoleHelper.currentRole();
    if (role != 'admin') {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Akses ditolak: hanya admin yang dapat menambah laporan',
          ),
        ),
      );
      return;
    }

    if (!mounted) return;

    final result = await navigator.push(
      MaterialPageRoute(
        builder: (context) => BuatLaporanKegiatanPage(masjid: widget.masjid),
      ),
    );

    if (result == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _downloadReport(EventEntity event) async {
    final buffer = StringBuffer()
      ..writeln(event.title)
      ..writeln(_formatDate(event.dateTime))
      ..writeln(event.location)
      ..writeln()
      ..writeln(event.deskripsi);

    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ringkasan laporan disalin ke clipboard')),
    );
  }

  List<EventEntity> _applyFilters(List<EventEntity> reports) {
    final query = _searchQuery.trim().toLowerCase();

    return reports.where((report) {
      final matchesQuery =
          query.isEmpty ||
          report.title.toLowerCase().contains(query) ||
          report.deskripsi.toLowerCase().contains(query) ||
          report.location.toLowerCase().contains(query);

      final matchesFilter = switch (_filter) {
        _ReportFilter.all => true,
        _ReportFilter.withImage =>
          report.imageUrl != null && report.imageUrl!.isNotEmpty,
        _ReportFilter.withoutImage =>
          report.imageUrl == null || report.imageUrl!.isEmpty,
      };

      return matchesQuery && matchesFilter;
    }).toList();
  }

  Future<void> _showFilterSheet() async {
    final chosen = await showModalBottomSheet<_ReportFilter>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.select_all),
                title: const Text('Semua laporan'),
                onTap: () => Navigator.pop(context, _ReportFilter.all),
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Dengan gambar'),
                onTap: () => Navigator.pop(context, _ReportFilter.withImage),
              ),
              ListTile(
                leading: const Icon(Icons.hide_image_outlined),
                title: const Text('Tanpa gambar'),
                onTap: () => Navigator.pop(context, _ReportFilter.withoutImage),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (chosen == null || !mounted) return;
    setState(() => _filter = chosen);
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_monthNames[date.month - 1]} ${date.year}';
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
        title: Text(widget.masjid?.title ?? 'Laporan Kegiatan'),
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
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfilePage()),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
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
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Laporan Kegiatan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari Laporan',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: _showFilterSheet,
                    ),
                  ),
                  const SizedBox(width: 8),
                  StreamBuilder<DocumentSnapshot>(
                    stream: sl<AuthRepository>().getCurrentUserStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(width: 44, height: 44);
                      }
                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return const SizedBox.shrink();
                      }

                      final userData =
                          snapshot.data!.data() as Map<String, dynamic>?;
                      final role = userData?['role'] ?? 'user';
                      if (role != 'admin') return const SizedBox.shrink();

                      return SizedBox(
                        height: 44,
                        width: 44,
                        child: ElevatedButton(
                          onPressed: _openCreatePage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: StreamBuilder<List<EventEntity>>(
                  stream: _reportsStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final reports = _applyFilters(snapshot.data ?? const []);

                    if (reports.isEmpty) {
                      return const Center(
                        child: Text('Tidak ada laporan kegiatan'),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: reports.length,
                      separatorBuilder: (context, _) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final report = reports[index];
                        return _ReportCard(
                          report: report,
                          dateText: _formatDate(report.dateTime),
                          onDownload: () => _downloadReport(report),
                          onOpen: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EventDetailPage(event: report),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final EventEntity report;
  final String dateText;
  final VoidCallback onDownload;
  final VoidCallback onOpen;

  const _ReportCard({
    required this.report,
    required this.dateText,
    required this.onDownload,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpen,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: const Color(0xFFE0E0E0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          dateText,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: onDownload,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(72, 28),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text('Unduh'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    report.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    report.deskripsi,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, height: 1.35),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: onOpen,
                    child: const Text(
                      'baca selengkapnya.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (report.imageUrl == null || report.imageUrl!.isEmpty) {
      return Container(
        height: 170,
        width: double.infinity,
        color: Colors.grey.shade300,
        child: const Center(
          child: Icon(Icons.image_outlined, size: 42, color: Colors.grey),
        ),
      );
    }

    return Builder(
      builder: (context) {
        final raw = report.imageUrl!;
        String safeUrl;
        try {
          safeUrl = Uri.parse(raw).toString();
        } catch (_) {
          safeUrl = raw.replaceAll(' ', '%20');
        }

        return Image.network(
          safeUrl,
          height: 170,
          width: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 170,
              color: Colors.grey.shade300,
              child: const Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 170,
              color: Colors.grey.shade300,
              child: const Center(
                child: Icon(Icons.broken_image_outlined, size: 42),
              ),
            );
          },
        );
      },
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
