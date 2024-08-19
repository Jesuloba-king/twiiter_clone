/*
AUTH GATE


Check if user is logged in or not

if user is logged in -> go to home page

if user is not -. go to register or login
*/

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:twitter_clone/components/services/auth/login_or_register.dart';
import 'package:twitter_clone/pages/homepage.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // user is logged in
            if (snapshot.hasData) {
              return const HomePage();
            } else {
              //user is not logged in
              return const LoginOrRegister();
            }
          }),
    );
  }
}
