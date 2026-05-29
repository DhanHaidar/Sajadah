import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sajadah/common/auth/role_helper.dart';
import 'package:sajadah/domain/repository/auth/auth.dart';
import 'package:sajadah/domain/entities/event/event.dart';
import 'package:sajadah/common/enums/kategori_event.dart';
import 'package:sajadah/domain/usecases/event/get_news_events.dart';
import 'package:sajadah/domain/usecases/event/get_events_by_masjid.dart';
import 'package:sajadah/presentation/events/pages/event_create_page.dart';
import 'package:sajadah/presentation/events/pages/event_detail_page.dart';
import 'package:sajadah/service_locator.dart';
import 'package:sajadah/domain/usecases/masjid/get_news_masjid.dart';
import 'package:sajadah/domain/entities/masjid/masjid_entity.dart';
import 'package:sajadah/common/widgets/app_drawer.dart';
import 'package:sajadah/common/widgets/profile_avatar.dart';

enum EventTimeFilter { all, today, thisWeek, thisMonth, upcoming, past }

enum EventFilterType { waktu, kategori }

class EventsPage extends StatefulWidget {
  final String? masjidId;
  final MasjidEntity? masjid;

  const EventsPage({super.key, this.masjidId, this.masjid});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  late Future<List<EventEntity>> _eventsFuture;
  EventFilterType _filterType = EventFilterType.waktu;
  EventTimeFilter _currentFilter = EventTimeFilter.all;
  KategoriEvent? _selectedKategoriFilter;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    _eventsFuture = _getEvents();
  }

  Future<List<EventEntity>> _getEvents() async {
    final masjidId = widget.masjidId ?? widget.masjid?.id;
    if (masjidId != null) {
      final result = await sl<GetEventsByMasjidUseCase>().call(
        params: GetEventsByMasjidParams(masjidId: masjidId),
      );
      return result.fold((error) {
        if (!mounted) return [];
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $error')));
        return [];
      }, (events) => events as List<EventEntity>);
    }

    final result = await sl<GetNewsEventsUseCase>().call();
    return result.fold((error) {
      if (!mounted) return [];
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $error')));
      return [];
    }, (events) => events as List<EventEntity>);
  }

  Future<void> _onCreatePressed() async {
    // Guard: only admin can create events
    final role = await RoleHelper.currentRole();
    if (role != 'admin') {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Akses ditolak: hanya admin yang dapat membuat event'),
        ),
      );
      return;
    }
    // If this page was opened for a specific masjid, create directly for it
    final masjidId = widget.masjidId ?? widget.masjid?.id;
    if (masjidId != null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              EventCreatePage(masjidId: masjidId, masjid: widget.masjid),
        ),
      );

      if (result == true) {
        setState(() {
          _loadEvents();
        });
      }

      return;
    }

    // Otherwise fallback to selecting a masjid like before
    final res = await sl<GetNewsMasjidsUseCase>().call();
    final masjidList = res.fold((error) {
      if (!mounted) return <MasjidEntity>[];
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengambil masjid: $error')));
      return <MasjidEntity>[];
    }, (data) => data as List<MasjidEntity>);

    if (masjidList.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Belum ada masjid. Tambahkan masjid terlebih dahulu.'),
        ),
      );
      return;
    }

    final chosen = await showDialog<MasjidEntity?>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Pilih Masjid'),
        children: masjidList
            .map(
              (m) => SimpleDialogOption(
                onPressed: () => Navigator.pop(context, m),
                child: Text(m.title),
              ),
            )
            .toList(),
      ),
    );

    if (chosen == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EventCreatePage(masjidId: chosen.id, masjid: chosen),
      ),
    );

    if (result == true) {
      setState(() {
        _loadEvents();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(masjid: widget.masjid),
      appBar: AppBar(
        title: Text(widget.masjid?.title ?? 'Event masjid '),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_outlined),
          ),
          const ProfileAvatar(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            // Search/filter/add row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari Event',
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
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () async {
                      final res =
                          await showModalBottomSheet<Map<String, dynamic>>(
                            context: context,
                            isScrollControlled: true,
                            builder: (ctx) {
                              EventFilterType localType = _filterType;
                              EventTimeFilter localTime = _currentFilter;
                              KategoriEvent? localKat = _selectedKategoriFilter;
                              return SafeArea(
                                child: StatefulBuilder(
                                  builder: (context, setLocalState) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              ChoiceChip(
                                                label: const Text('Waktu'),
                                                selected:
                                                    localType ==
                                                    EventFilterType.waktu,
                                                onSelected: (v) =>
                                                    setLocalState(
                                                      () => localType =
                                                          EventFilterType.waktu,
                                                    ),
                                              ),
                                              const SizedBox(width: 8),
                                              ChoiceChip(
                                                label: const Text('Kategori'),
                                                selected:
                                                    localType ==
                                                    EventFilterType.kategori,
                                                onSelected: (v) =>
                                                    setLocalState(
                                                      () => localType =
                                                          EventFilterType
                                                              .kategori,
                                                    ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          if (localType ==
                                              EventFilterType.waktu)
                                            ...EventTimeFilter.values.map((f) {
                                              String label;
                                              switch (f) {
                                                case EventTimeFilter.all:
                                                  label = 'Semua';
                                                  break;
                                                case EventTimeFilter.today:
                                                  label = 'Hari ini';
                                                  break;
                                                case EventTimeFilter.thisWeek:
                                                  label = 'Minggu ini';
                                                  break;
                                                case EventTimeFilter.thisMonth:
                                                  label = 'Bulan ini';
                                                  break;
                                                case EventTimeFilter.upcoming:
                                                  label = 'Mendatang';
                                                  break;
                                                case EventTimeFilter.past:
                                                  label = 'Lewat';
                                                  break;
                                              }
                                              return ListTile(
                                                title: Text(label),
                                                trailing: localTime == f
                                                    ? const Icon(
                                                        Icons.check,
                                                        color: Colors.green,
                                                      )
                                                    : null,
                                                onTap: () =>
                                                    Navigator.of(ctx).pop({
                                                      'type': 'time',
                                                      'filter': f,
                                                    }),
                                              );
                                            }).toList(),
                                          if (localType ==
                                              EventFilterType.kategori)
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                ListTile(
                                                  title: const Text(
                                                    'Semua Kategori',
                                                  ),
                                                  trailing: localKat == null
                                                      ? const Icon(
                                                          Icons.check,
                                                          color: Colors.green,
                                                        )
                                                      : null,
                                                  onTap: () =>
                                                      Navigator.of(ctx).pop({
                                                        'type': 'kategori',
                                                        'kategori': null,
                                                      }),
                                                ),
                                                ...KategoriEvent.values.map((
                                                  k,
                                                ) {
                                                  return ListTile(
                                                    title: Text(k.label),
                                                    trailing: localKat == k
                                                        ? const Icon(
                                                            Icons.check,
                                                            color: Colors.green,
                                                          )
                                                        : null,
                                                    onTap: () =>
                                                        Navigator.of(ctx).pop({
                                                          'type': 'kategori',
                                                          'kategori': k.value,
                                                        }),
                                                  );
                                                }).toList(),
                                              ],
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          );

                      if (res == null) return;
                      if (res['type'] == 'time' &&
                          res['filter'] is EventTimeFilter) {
                        setState(() {
                          _filterType = EventFilterType.waktu;
                          _currentFilter = res['filter'] as EventTimeFilter;
                          _selectedKategoriFilter = null;
                        });
                      } else if (res['type'] == 'kategori') {
                        setState(() {
                          _filterType = EventFilterType.kategori;
                          _selectedKategoriFilter = KategoriEventX.fromString(
                            res['kategori'] as String?,
                          );
                          _currentFilter = EventTimeFilter.all;
                        });
                      }
                    },
                    tooltip: 'Filter',
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
                      child: ElevatedButton(
                        onPressed: _onCreatePressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Event list
            Expanded(
              child: FutureBuilder<List<EventEntity>>(
                future: _eventsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final events = snapshot.data ?? [];

                  // Apply time-based filter
                  final filtered = events
                      .where((e) => _matchesFilter(e))
                      .toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text('Tidak ada event untuk filter ini'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final event = filtered[index];
                      return _buildEventCard(event);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(EventEntity event) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailPage(event: event),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image (top)
            if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
              SizedBox(
                height: 180,
                width: double.infinity,
                child: Builder(
                  builder: (context) {
                    final raw = event.imageUrl!;
                    String safeUrl;
                    try {
                      safeUrl = Uri.parse(raw).toString();
                    } catch (_) {
                      safeUrl = raw.replaceAll(' ', '%20');
                    }

                    return Image.network(
                      safeUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[300],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image_not_supported, size: 40),
                                SizedBox(height: 8),
                                Text(
                                  'Gambar tidak tersedia',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              )
            else
              Container(
                height: 180,
                width: double.infinity,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.image, size: 40, color: Colors.grey),
                ),
              ),

            // Grey info panel
            Container(
              width: double.infinity,
              color: Colors.grey[200],
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (event.kategori != null && event.kategori!.isNotEmpty)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            KategoriEventX.fromString(event.kategori)?.label ??
                                event.kategori!,
                            style: TextStyle(
                              color: Colors.green[800],
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${event.dateTime.day} ${_monthName(event.dateTime.month)} ${event.dateTime.year}',
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.location,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _monthName(int month) {
    const months = [
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
    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }

  bool _matchesFilter(EventEntity event) {
    // If current filter mode is kategori, apply category-based filtering
    if (_filterType == EventFilterType.kategori) {
      if (_selectedKategoriFilter == null) return true; // 'All categories'
      final eventCat = KategoriEventX.fromString(event.kategori);
      if (eventCat != null) {
        return eventCat == _selectedKategoriFilter;
      }
      if (event.kategori == null) return false;
      return event.kategori!.toLowerCase() == _selectedKategoriFilter!.value;
    }

    // Otherwise apply time-based filtering
    final now = DateTime.now();
    final dt = event.dateTime;

    bool inRange(DateTime a, DateTime start, DateTime end) {
      return !a.isBefore(start) && !a.isAfter(end);
    }

    switch (_currentFilter) {
      case EventTimeFilter.all:
        return true;
      case EventTimeFilter.today:
        return dt.year == now.year &&
            dt.month == now.month &&
            dt.day == now.day;
      case EventTimeFilter.thisWeek:
        final monday = now.subtract(Duration(days: now.weekday - 1));
        final sunday = monday.add(const Duration(days: 6));
        final start = DateTime(monday.year, monday.month, monday.day);
        final end = DateTime(
          sunday.year,
          sunday.month,
          sunday.day,
          23,
          59,
          59,
          999,
        );
        return inRange(dt, start, end);
      case EventTimeFilter.thisMonth:
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(
          now.year,
          now.month + 1,
          1,
        ).subtract(const Duration(milliseconds: 1));
        return inRange(dt, start, end);
      case EventTimeFilter.upcoming:
        return dt.isAfter(now);
      case EventTimeFilter.past:
        return dt.isBefore(now);
    }
  }
}
