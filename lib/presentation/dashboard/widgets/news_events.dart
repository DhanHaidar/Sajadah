import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:sajadah/domain/entities/event/event.dart';
import 'package:sajadah/domain/usecases/event/get_news_events.dart';
import 'package:sajadah/presentation/events/pages/event_page.dart';
import 'package:sajadah/service_locator.dart';

/// Widget untuk menampilkan list kegiatan/event
class NewsEventsWidget extends StatelessWidget {
  final int? maxItems;

  const NewsEventsWidget({super.key, this.maxItems});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Either>(
      future: sl<GetNewsEventsUseCase>().call(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData) {
          return const Center(child: Text("Tidak ada data kegiatan"));
        }

        return snapshot.data!.fold(
          (error) => Center(child: Text("Error: $error")),
          (events) {
            List<EventEntity> eventList = events as List<EventEntity>;

            // Batasi jumlah items jika maxItems diberikan
            if (maxItems != null && eventList.length > maxItems!) {
              eventList = eventList.sublist(0, maxItems);
            }

            return SizedBox(
              height: 230, // Set tinggi untuk horizontal scroll
              child: ListView.builder(
                scrollDirection: Axis.horizontal, // ← Scroll horizontal
                itemCount: eventList.length,
                itemBuilder: (context, index) {
                  var event = eventList[index];
                  return EventCard(event: event);
                },
              ),
            );
          },
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
          MaterialPageRoute(builder: (BuildContext context) => EventsPage()),
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
                if (event.speaker != null) ...[
                  Text(
                    "Pembicara: ${event.speaker}",
                    style: const TextStyle(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                ],

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
      child: Image.network(
        event.imageUrl!,
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
      ),
    );
  }
}
