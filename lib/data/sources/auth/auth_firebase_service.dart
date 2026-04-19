import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sajadah/data/models/auth/create_user_auth.dart';
import 'package:sajadah/data/models/auth/signin_user_req.dart';

abstract class AuthFirebaseService {
  Future<Either> signup(CreateUserReq createUserReq);
  Future<Either> signin(SigninUserReq signinUserReq);
}

class AuthFirebaseServiceImpl extends AuthFirebaseService {
  @override
  Future<Either> signin(SigninUserReq signinUserReq) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: signinUserReq.email!,
        password: signinUserReq.password!,
      );
      return Right("Signin was successful");
    } on FirebaseAuthException catch (e) {
      String message = "";

      if (e.code == 'user-not-found') {
        message = "No user found for that email.";
      } else if (e.code == 'wrong-password') {
        message = "Wrong password provided for that user.";
      }
      return Left(message);
    }
  }

  @override
  Future<Either> signup(CreateUserReq createUserReq) async {
    try {
      var data = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: createUserReq.email!,
        password: createUserReq.password!,
      );
      // Set the displayName on the Firebase user profile so it can be
      // retrieved later via FirebaseAuth.instance.currentUser.displayName
      if (data.user != null) {
        await data.user!.updateDisplayName(createUserReq.fullName);
        await data.user!.reload();
      }
      FirebaseFirestore.instance.collection('Users').doc(data.user?.uid).set({
        'name': createUserReq.fullName,
        'email': data.user?.email,
        'uid': data.user?.uid,
      });
      return Right("Signup was successful");
    } on FirebaseAuthException catch (e) {
      String message = "";

      if (e.code == 'weak-password') {
        message = "The password provided is too weak.";
      } else if (e.code == 'email-already-in-use') {
        message = "The account already exists for that email.";
      }
      return Left(message);

      // Handle authentication errors
    }
  }
}
