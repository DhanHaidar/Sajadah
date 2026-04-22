import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sajadah/core/configs/constants/app_urls.dart';
import 'package:sajadah/data/repository/auth/auth_repository_impl.dart';
import 'package:sajadah/domain/repository/auth/auth.dart';
import 'package:sajadah/presentation/dashboard/widgets/news_events.dart';
import 'package:sajadah/service_locator.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),

      // Display user info using StreamBuilder to listen to real-time updates
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              DisplayUserName(),
              const SizedBox(height: 20),
              const NewsEventsWidget(maxItems: 2),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 38, 202, 60),
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(AppURLs.supabaseStorage),
                    fit: BoxFit.cover,
                  ),
                ),
                child: const Center(
                  child: Text(
                    "Konten lainnya bisa ditambahkan di sini",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
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
