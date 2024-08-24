/*
Authentication Service

this  handles everything with athentication in firebase

-----------------
-Login
- Register
- Logout
- Delete Account (if required to publish to app store)
*/

import 'package:firebase_auth/firebase_auth.dart';

import '../database/database_service.dart';

class AuthService {
  //get instance of the auth
  final _auth = FirebaseAuth.instance;

  //get current user & uid
  User? getCurrentUser() => _auth.currentUser;
  String getCurrentUid() => _auth.currentUser!.uid;

  //login - email & psw
  Future<UserCredential> loginEmailPassword(String email, password) async {
    //attempt login
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential;
    }
    //catch any error
    on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  //register - email & pswd
  Future<UserCredential> registerEmailPassword(String email, password) async {
    //attempt register
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  //logout
  Future<void> logoutEmailPassword() async {
    //attempt logut
    await _auth.signOut();
  }

  ///delete account
  Future<void> deleteAccount() async {
    //get current UserId
    User? user = getCurrentUser();

    if (user != null) {
      //deelte user's data from firestore
      await DatabaseService().deleteUserInfoFromFireBase(user.uid);

      //delete the user's auth record
      await user.delete();
    }
    //attempt delete account
  }

//forgotPassword
  Future<void> forgotPasswordEmailPassword(String email) async {
    User? user = getCurrentUser();
    //attempt forgot password
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }
}
