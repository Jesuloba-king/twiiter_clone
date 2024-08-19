// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';

import '../../my_buttons.dart';
import '../../my_drawer.dart';
import '../../my_loading.dart';
import '../../my_textfiled.dart';
import 'auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.onTap});
  final void Function()? onTap;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  //access auth service
  final _auth = AuthService();
  bool _isObscure = true;

  //login method
  Future<void> login() async {
    //show loading

    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      showLoadingCircle(context);
      try {
        await _auth.loginEmailPassword(
            emailController.text, passwordController.text);

        //finished loading
        if (mounted) hideLoading(context);
      } catch (e) {
        if (mounted) hideLoading(context);
        // print(e.toString());
        CustomToast.show(
          backgroundColor: Colors.red.shade800,
          textColor: Colors.white,
          context: context,
          message: e.toString(),
          icon: Icons.error_outline_rounded, // Success icon
        );
      }
    } else {
      // if (mounted) hideLoading(context);
      CustomToast.show(
        backgroundColor: Colors.red.shade800,
        textColor: Colors.white,
        context: context,
        message: "All fields required",
        icon: Icons.error_outline_rounded, // Success icon
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //logo
                Icon(
                  Icons.girl_rounded,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary,
                ),

                const SizedBox(
                  height: 50,
                ),

                //welcome back message
                Text(
                  "Welcome back, you/'ve been missed!",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(
                  height: 25,
                ),

                //emai textfield
                MyTextfield(
                  controller: emailController,
                  hintText: "Enter email...",
                  obScureText: false,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(
                  height: 15,
                ),

                //password field
                MyTextfield(
                  controller: passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  obScureText: _isObscure,
                  hintText: "Enter passowrd...",
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                    icon: Icon(
                        _isObscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: _isObscure
                            ? Theme.of(context).colorScheme.primary
                            : Colors.black.withOpacity(0.55)),
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                //forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(
                  height: 25,
                ),

                //sign in button
                MyButton(
                  text: "Login",
                  onTap: login,
                ),

                const SizedBox(height: 50),

                //not registerd
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Not a member?",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        // fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        "Register now",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
