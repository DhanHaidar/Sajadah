import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sajadah/domain/entities/event/event.dart';
import 'package:sajadah/common/enums/kategori_event.dart';

class EventDetailPage extends StatelessWidget {
  final EventEntity event;
  const EventDetailPage({Key? key, required this.event}) : super(key: key);

  Future<void> _openMaps(BuildContext context) async {
    final query = Uri.encodeComponent(event.location);
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
      appBar: AppBar(title: Text(event.title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
              Builder(
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
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                  );
                },
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        '${event.dateTime.day}/${event.dateTime.month}/${event.dateTime.year} ${event.dateTime.hour}:${event.dateTime.minute.toString().padLeft(2, '0')}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (event.kategori != null && event.kategori!.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.label, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          KategoriEventX.fromString(event.kategori)?.label ??
                              event.kategori!,
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(event.location)),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => _openMaps(context),
                        icon: const Icon(Icons.map, size: 16),
                        label: const Text('Buka'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(64, 36),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (event.speaker != null) ...[
                    Text(
                      'Pembicara',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(event.speaker!),
                    const SizedBox(height: 12),
                  ],
                  Text(
                    'Deskripsi',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(event.deskripsi),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
