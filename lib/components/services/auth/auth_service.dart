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
}
