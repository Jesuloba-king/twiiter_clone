// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:twitter_clone/components/services/database/database_service.dart';

import '../../my_buttons.dart';
import '../../my_drawer.dart';
import '../../my_loading.dart';
import '../../my_textfiled.dart';
import 'auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, this.onTap});
  final void Function()? onTap;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController confamPassControl = TextEditingController();

  //access auth & db service
  final _auth = AuthService();
  final _db = DatabaseService();
  bool _isObscure = true;
  bool _isObscure2 = true;

  //login method
  Future<void> register() async {
    //password match, create user
    if (passwordController.text == confamPassControl.text) {
      //show loading
      showLoadingCircle(context);
      try {
        await _auth.registerEmailPassword(
            emailController.text, passwordController.text);

        //finished loading
        if (mounted) hideLoading(context);

        //once registered, create and save user profile in database
        await _db.saveUserInfoinFirebase(
            name: nameController.text, email: emailController.text);
      } catch (e) {
        if (mounted) hideLoading(context);
        print(e.toString());
        CustomToast.show(
          backgroundColor: Colors.red.shade800,
          textColor: Colors.white,
          context: context,
          message: e.toString(),
          icon: Icons.error_outline_rounded, // Success icon
        );
      }
    }

    //passwords dont match : show error
    else {
      CustomToast.show(
        backgroundColor: Colors.red.shade800,
        textColor: Colors.white,
        context: context,
        message: "Passwords don't match!!",
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
                  Icons.lock_open_rounded,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary,
                ),

                const SizedBox(
                  height: 50,
                ),

                //welcome back message
                Text(
                  "Let's create an accont for you",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(
                  height: 25,
                ),

                //name
                MyTextfield(
                  controller: nameController,
                  hintText: "Enter name...",
                  obScureText: false,
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(
                  height: 15,
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
                    hintText: "Enter passowrd..."),

                const SizedBox(
                  height: 15,
                ),
                MyTextfield(
                  controller: confamPassControl,
                  hintText: "Confirm password...",
                  obScureText: _isObscure2,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _isObscure2 = !_isObscure2;
                      });
                    },
                    icon: Icon(
                        _isObscure2
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: _isObscure2
                            ? Theme.of(context).colorScheme.primary
                            : Colors.black.withOpacity(0.55)),
                  ),
                  keyboardType: TextInputType.visiblePassword,
                ),
                const SizedBox(
                  height: 15,
                ),

                //forgot password
                // Align(
                //   alignment: Alignment.centerRight,
                //   child: Text(
                //     "Forgot Password?",
                //     style: TextStyle(
                //         color: Theme.of(context).colorScheme.primary,
                //         fontWeight: FontWeight.bold),
                //   ),
                // ),

                const SizedBox(
                  height: 25,
                ),

                //sign in button
                MyButton(
                  text: "Register",
                  onTap: register,
                ),

                const SizedBox(height: 50),

                //not registerd
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already a member?",
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
                      // onTap: () {
                      //   Navigator.push(context,
                      //       MaterialPageRoute(builder: (context) {
                      //     return const LoginPage();
                      //   }));
                      // },
                      child: Text(
                        "Login now",
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
