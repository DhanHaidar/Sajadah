import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sajadah/common/widgets/bottom_nav_bar.dart';
import 'package:sajadah/core/configs/assets/app_images.dart';
import 'package:sajadah/core/configs/constants/app_urls.dart';
import 'package:sajadah/data/repository/auth/auth_repository_impl.dart';
import 'package:sajadah/domain/repository/auth/auth.dart';
import 'package:sajadah/presentation/dashboard/widgets/news_events.dart';
import 'package:sajadah/presentation/events/pages/event_page.dart';
import 'package:sajadah/service_locator.dart';
import 'package:sajadah/domain/entities/masjid/masjid_entity.dart';

class Dashboard extends StatelessWidget {
  final MasjidEntity? masjid;
  const Dashboard({super.key, this.masjid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
        title: Text(masjid?.title ?? 'Dashboard'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
          // show small avatar with user initial
          StreamBuilder<DocumentSnapshot>(
            stream: sl<AuthRepository>().getCurrentUserStream(),
            builder: (context, snapshot) {
              String initial = 'U';
              if (snapshot.hasData && snapshot.data!.exists) {
                final data = snapshot.data!.data() as Map<String, dynamic>?;
                final name = data?['name'] as String?;
                if (name != null && name.isNotEmpty)
                  initial = name[0].toUpperCase();
              }
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: CircleAvatar(child: Text(initial)),
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting card
              DisplayUserName(masjidTitle: masjid?.title),
              const SizedBox(height: 20),

              // Event Terbaru
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Event Terbaru',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventsPage(masjidId: masjid?.id),
                        ),
                      );
                    },
                    child: const Text('Lihat Semua'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              NewsEventsWidget(maxItems: 5, masjidId: masjid?.id),
              const SizedBox(height: 20),

              // Donasi Terbaru (static sample list)
              const Text(
                'Donasi Terbaru',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Column(
                children: _donationItems
                    .map((d) => _buildDonationCard(d))
                    .toList(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class DisplayUserName extends StatelessWidget {
  final String? masjidTitle;
  const DisplayUserName({super.key, this.masjidTitle});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(AppImages.signupsigninBG, fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.45),
                    Colors.black.withOpacity(0.15),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder<DocumentSnapshot>(
                stream: sl<AuthRepository>().getCurrentUserStream(),
                builder: (context, snapshot) {
                  String userName = 'User';
                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>?;
                    userName = (data?['name'] as String?) ?? userName;
                  }

                  final today = DateTime.now();
                  final dateStr =
                      '${_weekdayName(today.weekday)}, ${today.day} ${_monthName(today.month)} ${today.year}';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dateStr,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Assalamu\'alaikum $userName',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        masjidTitle ?? 'Semoga Hari Ini Penuh Keberkahan',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _weekdayName(int w) {
    const names = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return names[(w - 1) % 7];
  }

  String _monthName(int m) {
    const names = [
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
    return names[(m - 1) % 12];
  }
}

// Sample donation items (static placeholder to mirror design)
const List<Map<String, String>> _donationItems = [
  {'title': 'Dana TPQ', 'total': '2.300.000', 'target': '5.000.000'},
  {
    'title': 'Pembangunan Masjid',
    'total': '10.120.000',
    'target': '15.600.000',
  },
  {
    'title': 'Bakti Sosial Ramadhan',
    'total': '4.200.000',
    'target': '5.000.000',
  },
  {'title': 'Pengajian Besar', 'total': '1.500.000', 'target': '2.000.000'},
];

Widget _buildDonationCard(Map<String, String> d) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 6),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              d['title'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'total : ${d['total']}',
                style: const TextStyle(color: Colors.grey),
              ),
              Text(
                'target : ${d['target']}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
