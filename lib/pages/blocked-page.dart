// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/services/database/database_provider.dart';

class BlockedUsersPage extends StatefulWidget {
  const BlockedUsersPage({super.key});

  @override
  State<BlockedUsersPage> createState() => _BlockedUsersPageState();
}

class _BlockedUsersPageState extends State<BlockedUsersPage> {
  //providers
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
//
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  @override
  void initState() {
    loadBlockedUsers();
    super.initState();
  }

  Future<void> loadBlockedUsers() async {
    await databaseProvider.loadBlockedUsers();
  }

//show confirmation unblock box
  _showUnblockBox(String userID) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Unblock User"),
        content: const Text("Are you sure you want to unblock this user?"),
        actions: <Widget>[
          TextButton(
            child: const Text("Cancel"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),

          //report button
          TextButton(
            child: const Text("Unblock"),
            onPressed: () async {
              //handle report action
              await databaseProvider.unblockUser(userID);

              Navigator.pop(context);

              //ley user know...
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("User unblocked!")));
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final blockedUsers = listeningProvider.blockedUsers;
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Blocked Users"),
          foregroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: blockedUsers.isEmpty
            ? const Center(
                child: const Text('No blocked users..'),
              )
            : ListView.builder(
                itemCount: blockedUsers.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final blockedUser = blockedUsers[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      // tileColor: Theme.of(context).colorScheme.secondary,
                      title: Text(blockedUser.name),
                      subtitle: Text("@${blockedUser.username}"),
                      trailing: IconButton(
                          onPressed: () => _showUnblockBox(blockedUser.uid),
                          icon: Icon(
                            Icons.block,
                            color: Theme.of(context).colorScheme.primary,
                          )),
                    ),
                  );
                }));
  }
}
