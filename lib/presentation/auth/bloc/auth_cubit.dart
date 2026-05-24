import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sajadah/domain/entities/auth/user.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  // Fungsi untuk mengecek siapa yang sedang login saat ini
  void checkCurrentUser() {
    emit(AuthLoading());
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      
      if (firebaseUser != null) {
        // Mapping data dari Firebase ke Entity milikmu
        final userEntity = UserEntities(
          userId: firebaseUser.uid,
          fullName: firebaseUser.displayName ?? 'Hamba Allah', 
          email: firebaseUser.email ?? 'hamba_allah@sajadah.app',
        );
        emit(AuthAuthenticated(userEntity));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }
}