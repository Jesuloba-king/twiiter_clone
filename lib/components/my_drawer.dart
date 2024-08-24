// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:twitter_clone/components/services/auth/auth_service.dart';
import 'package:twitter_clone/pages/profile.dart';

import '../pages/homepage.dart';
import '../pages/search_page.dart';
import '../pages/settings.dart';
import 'my_loading.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool fingerprintEnabled = false;

  final _auth = AuthService();
  //logout
  void logout() {
    showLoadingCircle(context);
    try {
      _auth.logoutEmailPassword();
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      //   return const LoginOrRegister();
      // }));

      //hide loading
      if (mounted) hideLoading(context);
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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // void _toggleSwitch() {
  //   setState(() {
  //     fingerprintEnabled = !fingerprintEnabled;
  //     if (fingerprintEnabled) {
  //       _controller.forward();
  //     } else {
  //       _controller.reverse();
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    // final state = ref.watch(loginProvider);
    // final model = ref.read(loginProvider.notifier);
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                // DrawerHeader(
                //   child: Icon(
                //     Icons.person,
                //     size: 72,
                //     color: Theme.of(context).colorScheme.primary,
                //   ),
                // ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50.0),
                  child: Icon(
                    Icons.person,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

                Divider(
                  indent: 25,
                  endIndent: 25,
                  color: Theme.of(context).colorScheme.secondary,
                ),

                const SizedBox(
                  height: 20,
                ),

                //home
                MyListTile(
                    text: "H O M E",
                    icon: Icons.home_filled,
                    onTap: () {
                      Navigator.pop(context);

                      //
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const HomePage();
                      }));
                    }),

                //reprint
                MyListTile(
                  text: "P RO F I L E",
                  icon: Icons.person,
                  onTap: () {
                    Navigator.pop(context);
                    //
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return ProfilePage(
                        uid: _auth.getCurrentUid(),
                      );
                    }));
                  },
                ),

                //search
                MyListTile(
                  text: "S E A R C H",
                  icon: Icons.search_rounded,
                  onTap: () {
                    Navigator.pop(context);
                    //
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return SearchPage(
                          // uid: _auth.getCurrentUid(),
                          );
                    }));
                  },
                ),

                //phone
                MyListTile(
                    text: "S E T T I N G S",
                    icon: Icons.settings_rounded,
                    onTap: () {
                      Navigator.pop(context);

                      //
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const SettingsPage();
                      }));
                    }),

                //fingerprint
                // Padding(
                //   padding: const EdgeInsets.only(left: 23),
                //   child: ListTile(
                //     leading: const Icon(
                //       Icons.fingerprint,
                //       color: Colors.grey,
                //     ),
                //     title: const Text("Enable Biometric"),
                //     trailing: Transform.scale(
                //       scale: 0.6,
                //       // _controller.value,
                //       child: CupertinoSwitch(
                //         value: state.hasEnabledBiometricLogin,
                //         activeColor: AppColors.primaryColor,
                //         thumbColor: Colors.white,
                //         onChanged: (value) {
                //           model.enableBiometricLogin(value);
                //           showFingerprintDialog(value);
                //         },
                //       ),
                //     ),
                //     // onTap: onTap,
                //   ),
                // ),
              ],
            ),

            //exit shop tile
            Padding(
              padding: const EdgeInsets.only(bottom: 28.0),
              child: MyListTile(
                text: 'L O G O U T',
                onTap: logout,
                icon: Icons.logout_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showFingerprintDialog(bool value) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shadowColor: Colors.white,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(
          value ? 'Biometric Enabled' : 'Biometric Disabled',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
        content: Text(
          value
              ? 'Fingerprint / Face ID has been enabled.'
              : 'Fingerprint / Face ID has been disabled.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(fontSize: 20, color: Colors.green),
            ),
          ),
        ],
      ),
    );
    // Perform the desired action based on the toggle value
    // Example: Enable or disable fingerprint authentication
  }
}

class MyListTile extends StatelessWidget {
  const MyListTile(
      {super.key, required this.text, this.icon, this.onTap, this.trailing});

  final String text;
  final IconData? icon;
  final Widget? trailing;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 23),
      child: ListTile(
        leading: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          text,
          style: TextStyle(
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}

class CustomToast {
  static void show({
    required BuildContext context,
    required String message,
    required IconData icon,
    required Color backgroundColor,
    required Color textColor,
  }) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50.0,
        left: MediaQuery.of(context).size.width * 0.019,
        right: MediaQuery.of(context).size.width * 0.019,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: double.infinity,
            height: 60,

            padding: const EdgeInsets.all(8),
            // const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 10.0),
                Icon(icon, color: textColor),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                        color: textColor,
                        // fontSize: 16.0,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Add the overlay entry to the overlay
    overlay.insert(overlayEntry);

    // Remove the overlay entry after a delay
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }
}
