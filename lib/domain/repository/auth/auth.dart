import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:sajadah/data/models/auth/create_user_auth.dart';
import 'package:sajadah/data/models/auth/signin_user_req.dart';

abstract class AuthRepository {
  Future<Either> signup(CreateUserReq createUserReq);
  Future<Either> signin(SigninUserReq signinUserReq);
  Future<Either> getCurrentUser();
  Stream<DocumentSnapshot> getCurrentUserStream();
  
}
