import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sajadah/domain/repository/auth/auth.dart';
import 'package:sajadah/presentation/masjid/widget/news_masjid.dart';
import 'package:sajadah/presentation/masjid/pages/masjid_create_page.dart';
import 'package:sajadah/service_locator.dart';

class MasjidPages extends StatelessWidget {
  const MasjidPages({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("MasjidPages")),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MasjidCreatePage()),
          );
          if (result == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Masjid berhasil ditambahkan')),
            );
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Tambah Masjid',
      ),

      // Display user info using StreamBuilder to listen to real-time updates
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              DisplayUserName(),
              const SizedBox(height: 20),
              const NewsMasjid(maxItems: 5),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class DisplayUserName extends StatelessWidget {
  const DisplayUserName({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(7),
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 38, 202, 60),
        borderRadius: BorderRadius.circular(12),
      ),
      child: StreamBuilder<DocumentSnapshot>(
        stream: sl<AuthRepository>().getCurrentUserStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Text("User data not found");
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;
          String userName = userData['name'] ?? 'User';
          String userEmail = userData['email'] ?? '';

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Selamat datang, $userName!",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                userEmail,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          );
        },
      ),
    );
  }
}
