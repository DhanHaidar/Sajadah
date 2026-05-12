import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sajadah/domain/entities/event/event.dart';
import 'package:sajadah/data/models/Event/event.dart';
import 'package:sajadah/domain/usecases/event/get_news_events.dart';
import 'package:sajadah/presentation/dashboard/pages/dashboard.dart';
import 'package:sajadah/presentation/events/pages/event_page.dart';
import 'package:sajadah/presentation/events/pages/event_detail_page.dart';
import 'package:sajadah/service_locator.dart';
import 'package:sajadah/domain/usecases/event/get_events_by_masjid.dart';

// Optional: if `masjidId` is provided, this widget shows events for that masjid's subcollection.

/// Widget untuk menampilkan list kegiatan/event
class NewsEventsWidget extends StatelessWidget {
  final int? maxItems;
  final String? masjidId;

  const NewsEventsWidget({super.key, this.maxItems, this.masjidId});

  @override
  Widget build(BuildContext context) {
    // Build a Firestore stream so UI updates in realtime when events change.
    final Stream<QuerySnapshot<Map<String, dynamic>>> stream = masjidId == null
        ? FirebaseFirestore.instance
              .collectionGroup('Kegiatan')
              .orderBy('waktu', descending: true)
              .snapshots()
        : FirebaseFirestore.instance
              .collection('Masjid')
              .doc(masjidId)
              .collection('Kegiatan')
              .orderBy('waktu', descending: true)
              .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(child: Text('Tidak ada data kegiatan'));
        }

        List<EventEntity> eventList = docs.map((doc) {
          final data = doc.data();
          String? derivedMasjidId;
          try {
            derivedMasjidId = doc.reference.parent.parent?.id;
          } catch (_) {
            derivedMasjidId = null;
          }

          final model = EventModel.fromJson(
            data,
            docId: doc.id,
            masjidId: derivedMasjidId,
          );
          return model.toEntity();
        }).toList();

        if (maxItems != null && eventList.length > maxItems!) {
          eventList = eventList.sublist(0, maxItems);
        }

        return SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: eventList.length,
            itemBuilder: (context, index) {
              final event = eventList[index];
              return EventCard(event: event);
            },
          ),
        );
      },
    );
  }
}

/// Widget untuk menampilkan satu event card
class EventCard extends StatelessWidget {
  final EventEntity event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => EventDetailPage(event: event),
          ),
        );
      },
      child: SizedBox(
        width: 197, // Set width fixed untuk kartu
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
                  EventImage(event: event),

                // Title
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Deskripsi
                // Expanded(
                //   child: Text(
                //     event.deskripsi,
                //     style: const TextStyle(fontSize: 12, color: Colors.grey),
                //     maxLines: 2,
                //     overflow: TextOverflow.ellipsis,
                //   ),
                // ),
                // const SizedBox(height: 8),

                // Speaker
                // if (event.speaker != null) ...[
                //   Text(
                //     "Pembicara: ${event.speaker}",
                //     style: const TextStyle(fontSize: 11),
                //     maxLines: 1,
                //     overflow: TextOverflow.ellipsis,
                //   ),
                //   const SizedBox(height: 4),
                // ],

                // Waktu
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "${event.dateTime.day}/${event.dateTime.month}/${event.dateTime.year}",
                        style: const TextStyle(fontSize: 10),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Lokasi
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        event.location,
                        style: const TextStyle(fontSize: 10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EventImage extends StatelessWidget {
  const EventImage({super.key, required this.event});

  final EventEntity event;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(8),
        topRight: Radius.circular(8),
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
            height: 120,
            width: double.infinity,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                height: 120,
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 120,
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported),
              );
            },
          );
        },
      ),
    );
  }
}
