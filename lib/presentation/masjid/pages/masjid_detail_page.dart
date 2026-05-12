import 'package:flutter/material.dart';
import 'package:sajadah/domain/entities/masjid/masjid_entity.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sajadah/domain/entities/event/event.dart';
import 'package:sajadah/domain/usecases/event/get_events_by_masjid.dart';
import 'package:sajadah/presentation/events/pages/event_create_page.dart';
import 'package:sajadah/presentation/events/pages/event_detail_page.dart';
import 'package:sajadah/presentation/jamaah/pages/jamaah_page.dart';
import 'package:sajadah/service_locator.dart';

class MasjidDetailPage extends StatefulWidget {
  final MasjidEntity masjid;
  const MasjidDetailPage({Key? key, required this.masjid}) : super(key: key);

  @override
  State<MasjidDetailPage> createState() => _MasjidDetailPageState();
}

class _MasjidDetailPageState extends State<MasjidDetailPage> {
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
    final result = await sl<GetEventsByMasjidUseCase>().call(
      params: GetEventsByMasjidParams(masjidId: widget.masjid.id ?? ''),
    );
    return result.fold((error) {
      if (!mounted) return [];
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $error')));
      return [];
    }, (events) => events as List<EventEntity>);
  }

  Future<void> _openMaps() async {
    final query = Uri.encodeComponent(widget.masjid.location);
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak bisa membuka Maps')),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal membuka Maps')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.masjid.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.masjid.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(widget.masjid.location),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _openMaps,
              icon: const Icon(Icons.map),
              label: const Text('Buka di Maps'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        JamaahPage(masjidId: widget.masjid.id),
                  ),
                );
              },
              icon: const Icon(Icons.people),
              label: const Text('Daftar Jamaah'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Kegiatan di masjid ini',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
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
                  if (events.isEmpty)
                    return const Center(child: Text('Belum ada kegiatan'));
                  return ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) =>
                        _buildEventCard(events[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventCreatePage(masjidId: widget.masjid.id),
            ),
          );
          if (result == true) {
            setState(() {
              _loadEvents();
            });
          }
        },
        child: const Icon(Icons.add),
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
        margin: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
              SizedBox(
                height: 200,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
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
                                value:
                                    loadingProgress.expectedTotalBytes != null
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
                ),
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[200],
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image, size: 40, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Tidak ada gambar',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.deskripsi,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.location_on, event.location),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.calendar_today,
                    '${event.dateTime.day}/${event.dateTime.month}/${event.dateTime.year} ${event.dateTime.hour}:${event.dateTime.minute.toString().padLeft(2, '0')}',
                  ),
                  if (event.speaker != null) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.person, event.speaker!),
                  ],
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
}
