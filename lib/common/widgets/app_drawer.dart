import 'package:flutter/material.dart';
import 'package:sajadah/domain/entities/masjid/masjid_entity.dart';
import 'package:sajadah/common/widgets/bottom_nav_bar.dart';
import 'package:sajadah/presentation/laporan_kegiatan/pages/laporan_kegiatan_page.dart';

class AppDrawer extends StatelessWidget {
  final MasjidEntity? masjid;
  const AppDrawer({super.key, this.masjid});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      (masjid?.title.isNotEmpty ?? false)
                          ? masjid!.title[0].toUpperCase()
                          : 'M',
                      style: const TextStyle(color: Colors.green),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          masjid?.title ?? 'Masjid',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (masjid?.location != null)
                          Text(
                            masjid!.location,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AppBottomNav(masjid: masjid, initialIndex: 0),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Event'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AppBottomNav(masjid: masjid, initialIndex: 1),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.article_outlined),
              title: const Text('Laporan Kegiatan'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LaporanKegiatanPage(masjid: masjid),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Jamaah'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AppBottomNav(masjid: masjid, initialIndex: 2),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Donasi'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AppBottomNav(masjid: masjid, initialIndex: 3),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('Keuangan'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AppBottomNav(masjid: masjid, initialIndex: 4),
                  ),
                );
              },
            ),

            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Pengaturan'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
