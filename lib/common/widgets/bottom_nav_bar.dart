import 'package:flutter/material.dart';
import 'package:sajadah/presentation/dashboard/pages/dashboard.dart';
import 'package:sajadah/presentation/events/pages/event_page.dart';
import 'package:sajadah/domain/entities/masjid/masjid_entity.dart';
import 'package:sajadah/presentation/jamaah/pages/jamaah_page.dart';

/// App-wide bottom navigation that switches between Dashboard and Events.
///
/// Usage: Place `AppBottomNav()` as the app's home widget, or embed it
/// where you want a full-screen scaffold with bottom navigation.
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
      // Dashboard can accept an optional MasjidEntity
      Dashboard(masjid: widget.masjid),
      EventsPage(masjidId: widget.masjid?.id),
      JamaahPage(masjidId: widget.masjid?.id),
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Event'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Jamaah'),
        ],
      ),
    );
  }
}
