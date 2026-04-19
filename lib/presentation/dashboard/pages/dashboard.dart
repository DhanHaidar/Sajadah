import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sajadah/common/widgets/appbar/main_appbar.dart';

class Dashboard extends StatelessWidget {
  Dashboard({super.key});
  final List<String> prayerTimes = [
    "Subuh: 04:30",
    "Dzuhur: 12:00",
    "Ashar: 15:30",
    "Maghrib: 18:00",
    "Isya: 19:30",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppbar(title: const Text('Dashboard')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 8.0),
          child: Column(children: [_homeTopCard()]),
        ),
      ),
    );
  }

  Widget _homeTopCard() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          height: 140,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 46, 194, 78),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Builder(
                  builder: (context) {
                    final user = FirebaseAuth.instance.currentUser;
                    final greetingName =
                        (user != null &&
                            user.displayName != null &&
                            user.displayName!.isNotEmpty)
                        ? user.displayName!
                        : 'Pengguna';
                    return Text('Assalamualaikum $greetingName');
                  },
                ),
                SizedBox(height: 10),
                Text("Selamat datang kembali"),
                SizedBox(height: 10),
                _prayerTimeCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _prayerTimeCard() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: prayerTimes.map((time) {
          return Container(
            margin: const EdgeInsets.only(right: 8.0),
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: Color.fromRGBO(255, 255, 255, 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(time, style: const TextStyle(color: Colors.white)),
          );
        }).toList(),
      ),
    );
  }
}
