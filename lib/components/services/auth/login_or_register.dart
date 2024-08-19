import 'package:flutter/material.dart';
import 'package:twitter_clone/components/services/auth/login_page.dart';

import 'register_page.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  //initially show login page
  bool _showLogin = true;

  //toggle between login & register page
  void _toggle() {
    setState(() {
      _showLogin = !_showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showLogin) {
      return LoginPage(
        onTap: _toggle,
      );
    } else {
      return RegisterPage(
        onTap: _toggle,
      );
    }
  }
}
