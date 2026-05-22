import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sajadah/service_locator.dart';
import 'package:sajadah/domain/repository/auth/auth.dart';

/// Small helper to read the current user's role from the Users document.
class RoleHelper {
  /// Returns the role string (e.g. 'admin' or 'user'), or null on error.
  static Future<String?> currentRole() async {
    try {
      final res = await sl<AuthRepository>().getCurrentUser();
      String? role;
      res.fold((l) => role = null, (data) {
        if (data is DocumentSnapshot) {
          final map = data.data() as Map<String, dynamic>?;
          role = map?['role'] as String?;
        } else if (data is Map<String, dynamic>) {
          role = data['role'] as String?;
        } else if (data is Map) {
          role = data['role']?.toString();
        }
      });
      return role;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> isAdmin() async {
    final r = await currentRole();
    return r == 'admin';
  }
}
