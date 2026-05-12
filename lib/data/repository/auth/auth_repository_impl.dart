import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:sajadah/data/models/auth/create_user_auth.dart';
import 'package:sajadah/data/models/auth/signin_user_req.dart';
import 'package:sajadah/data/sources/auth/auth_firebase_service.dart';
import 'package:sajadah/domain/repository/auth/auth.dart';
import 'package:sajadah/service_locator.dart';

class AuthRepositoryImpl extends AuthRepository {
  @override
  Future<Either> signin(SigninUserReq signinUserReq) async {
    return await sl<AuthFirebaseService>().signin(signinUserReq);
  }

  @override
  Future<Either> signup(CreateUserReq createUserReq) async {
    return await sl<AuthFirebaseService>().signup(createUserReq);
  }


  @override
  Future<Either> getCurrentUser() async {
    return await sl<AuthFirebaseService>().getCurrentUser();
  }

  @override
  Stream<DocumentSnapshot> getCurrentUserStream() {
    return sl<AuthFirebaseService>().getCurrentUserStream();
  }
}
