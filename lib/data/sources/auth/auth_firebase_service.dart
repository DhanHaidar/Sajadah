import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sajadah/data/models/auth/create_user_auth.dart';
import 'package:sajadah/data/models/auth/signin_user_req.dart';

abstract class AuthFirebaseService {
  Future<Either> signup(CreateUserReq createUserReq);
  Future<Either> signin(SigninUserReq signinUserReq);
  // New methods to get current user info
  Future<Either> getCurrentUser();
  Stream<DocumentSnapshot> getCurrentUserStream();
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
        'role': createUserReq.role ?? 'user',
        'createdAt': FieldValue.serverTimestamp(),
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

  // New methods to get current user info

  @override
  Future<Either> getCurrentUser() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return Left("No user logged in");
      }

      //ambil data user dari Firestore berdasarkan UID dari FirebaseAuth
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .get();
      //ambil data user dari Firestore berdasarkan UID dari FirebaseAuth

      if (!userDoc.exists) {
        return Left("User data not found");
      }

      return Right(userDoc.data());
    } catch (e) {
      return Left("Error fetching user: $e");
    }
  }

  // Stream to listen for real-time updates to the current user's data

  @override
  Stream<DocumentSnapshot> getCurrentUserStream() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Stream.error("No user logged in");
    }

    return FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser.uid)
        .snapshots();
  }
}
