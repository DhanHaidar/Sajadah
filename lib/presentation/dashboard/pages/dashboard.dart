import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blueAccent,
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
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const NewsEventsWidget(maxItems: 2),
          ],
        ),
      ),
    );
  }
}
