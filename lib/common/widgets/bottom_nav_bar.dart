import 'package:flutter/material.dart';
import 'package:sajadah/presentation/dashboard/pages/dashboard.dart';
import 'package:sajadah/presentation/events/pages/event_page.dart';
import 'package:sajadah/domain/entities/masjid/masjid_entity.dart';
import 'package:sajadah/presentation/jamaah/pages/jamaah_page.dart';
import 'package:sajadah/presentation/donasi/pages/donasi_list_page.dart'; // IMPORT HALAMAN BARU

class AppBottomNav extends StatefulWidget {
  final int initialIndex;
  final MasjidEntity? masjid;

  const AppBottomNav({Key? key, this.initialIndex = 0, this.masjid})
    : super(key: key);

  @override
  State<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav> {
  late int _currentIndex;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pages = [
      Dashboard(masjid: widget.masjid),
      EventsPage(masjidId: widget.masjid?.id),
      DonasiListPage(masjid: widget.masjid), // TAB BARU: DONASI (Index 2)
      JamaahPage(masjidId: widget.masjid?.id), // Jamaah geser ke Index 3
    ];
  }

  void _onTap(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        type: BottomNavigationBarType.fixed, // Tambahkan ini agar warna/ikon tidak aneh jika lebih dari 3 tab
        selectedItemColor: Colors.green, // Sesuaikan dengan warna brand aplikasimu
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Event'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Donasi'), // IKON DONASI
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Jamaah'),
        ],
      ),
    );
  }
}