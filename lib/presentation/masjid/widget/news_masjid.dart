import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
//import 'package:sajadah/domain/entities/masjid/masjid.dart';
import 'package:sajadah/domain/entities/masjid/masjid_entity.dart';
//import 'package:sajadah/domain/usecases/masjid/get_news_events.dart';
import 'package:sajadah/domain/usecases/masjid/get_news_masjid.dart';
import 'package:sajadah/common/widgets/bottom_nav_bar.dart';
import 'package:sajadah/presentation/events/pages/event_page.dart';
import 'package:sajadah/presentation/masjid/pages/masjid_detail_page.dart';
import 'package:sajadah/service_locator.dart';

/// Widget untuk menampilkan list kegiatan/masjid
class NewsMasjid extends StatelessWidget {
  final int? maxItems;

  const NewsMasjid({super.key, this.maxItems});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Either>(
      future: sl<GetNewsMasjidsUseCase>().call(),
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
            List<MasjidEntity> masjidList = events as List<MasjidEntity>;

            // Batasi jumlah items jika maxItems diberikan
            if (maxItems != null && masjidList.length > maxItems!) {
              masjidList = masjidList.sublist(0, maxItems);
            }

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.85,
                ),
                itemCount: masjidList.length,
                itemBuilder: (context, index) {
                  final masjid = masjidList[index];
                  return MasjidCard(masjid: masjid);
                },
              ),
            );
          },
        );
      },
    );
  }
}

/// Widget untuk menampilkan satu masjid card
class MasjidCard extends StatelessWidget {
  final MasjidEntity masjid;

  const MasjidCard({super.key, required this.masjid});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => AppBottomNav(masjid: masjid),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (masjid.imageUrl != null && masjid.imageUrl!.isNotEmpty)
                MasjidImage(masjid: masjid),

              // Title
              Text(
                masjid.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Lokasi
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      masjid.location,
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
    );
  }
}

class MasjidImage extends StatelessWidget {
  const MasjidImage({super.key, required this.masjid});

  final MasjidEntity masjid;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(8),
        topRight: Radius.circular(8),
      ),
      child: Builder(
        builder: (context) {
          final raw = masjid.imageUrl!;
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
