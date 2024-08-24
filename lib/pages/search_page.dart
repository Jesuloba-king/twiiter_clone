import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/components/my_userList_tile.dart';

import '../components/services/database/database_provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchContr0ller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    //
    final listeningProvider = Provider.of<DatabaseProvider>(context);
//
    final databaseProvider =
        Provider.of<DatabaseProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: TextField(
          controller: _searchContr0ller,
          onChanged: (value) {
            // Handle search query changes here
            if (value.isNotEmpty) {
              databaseProvider.searchUsers(value);
            }
            //clear results
            else {
              databaseProvider.searchUsers("");
            }
          },
          decoration: InputDecoration(
            hintText: 'Search users..',
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
            border: InputBorder.none,
          ),
        ),
      ),
      body: listeningProvider.searchResults.isEmpty
          ?
          //no users found..
          Center(
              child: Text("No Users found.."),
            )
          : ListView.builder(
              itemCount: listeningProvider.searchResults.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final user = listeningProvider.searchResults[index];
                return MyUserListTile(user: user);
              },
            ),
    );
  }
}
