import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:sajadah/domain/entities/event/event.dart';
import 'package:sajadah/domain/repository/event/event.dart';
import 'package:sajadah/domain/usecases/event/get_news_events.dart';
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

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: eventList.length,
              itemBuilder: (context, index) {
                var event = eventList[index];
                return EventCard(event: event);
              },
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
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              event.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // // Deskripsi
            // Text(
            //   event.deskripsi,
            //   style: const TextStyle(fontSize: 14, color: Colors.grey),
            // ),
            // const SizedBox(height: 8),

            // Speaker
            if (event.speaker != null) ...[
              Text(
                "Pembicara: ${event.speaker}",
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 8),
            ],

            // Waktu
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 8),
                Text(
                  "${event.dateTime.day}/${event.dateTime.month}/${event.dateTime.year} "
                  "${event.dateTime.hour.toString().padLeft(2, '0')}:"
                  "${event.dateTime.minute.toString().padLeft(2, '0')}",
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Lokasi
            Row(
              children: [
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    event.location,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
