import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sajadah/domain/repository/auth/auth.dart';
import 'package:sajadah/presentation/profile/profile_page.dart';
import 'package:sajadah/service_locator.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: sl<AuthRepository>().getCurrentUserStream(),
      builder: (context, snapshot) {
        String initial = 'U';
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final name = data?['name'] as String?;
          if (name != null && name.isNotEmpty) initial = name[0].toUpperCase();
        }

        return Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: InkWell(
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ProfilePage())),
            borderRadius: BorderRadius.circular(20),
            child: CircleAvatar(
              radius: 15,
              backgroundColor: Colors.green,
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
