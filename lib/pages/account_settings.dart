import 'package:flutter/material.dart';
import 'package:twitter_clone/components/services/auth/auth_service.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  //confirm account deleteion
  void confirmDeletion(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text("Are you sure you want to delete this account?"),
        actions: <Widget>[
          TextButton(
            child: const Text("Cancel"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),

          //delete button
          TextButton(
            child: const Text("Delete"),
            onPressed: () async {
              //handle report action
              await AuthService().deleteAccount();

              //close dialog

              // Navigator.pop(context);

              //navigate to login page
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);

              //ley user know...
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Account Deleted!")));
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("Account Settings"),
        centerTitle: true,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          //Delete tile
          GestureDetector(
            onTap: () => confirmDeletion(context),
            child: Container(
              padding: const EdgeInsets.all(25),
              margin: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: const Text(
                  "Delete Account",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
