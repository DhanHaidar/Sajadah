import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Minimal AuthCubit used to check current Firebase user.
class AuthCubit extends Cubit<User?> {
  AuthCubit() : super(null);

  /// Check currently signed-in user and emit it if present.
  Future<void> checkCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) emit(user);
  }
}
