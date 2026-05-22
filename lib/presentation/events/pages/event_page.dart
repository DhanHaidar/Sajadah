import 'package:flutter/material.dart';
import 'package:sajadah/domain/entities/event/event.dart';
import 'package:sajadah/domain/usecases/event/get_news_events.dart';
import 'package:sajadah/domain/usecases/event/get_events_by_masjid.dart';
import 'package:sajadah/presentation/events/pages/event_create_page.dart';
import 'package:sajadah/presentation/events/pages/event_detail_page.dart';
import 'package:sajadah/service_locator.dart';
import 'package:sajadah/domain/usecases/masjid/get_news_masjid.dart';
import 'package:sajadah/domain/entities/masjid/masjid_entity.dart';
import 'package:sajadah/common/widgets/app_drawer.dart';

class EventsPage extends StatefulWidget {
  final String? masjidId;
  final MasjidEntity? masjid;

  const EventsPage({super.key, this.masjidId, this.masjid});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  late Future<List<EventEntity>> _eventsFuture;

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
      appBar: AppBar(title: Text(widget.masjid?.title ?? 'Event masjid ')),
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
                    onPressed: () {},
                    tooltip: 'Filter',
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
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

                  if (events.isEmpty) {
                    return const Center(
                      child: Text('Tidak ada event saat ini'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
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
}
