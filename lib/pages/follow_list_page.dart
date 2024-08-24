// ignore_for_file: await_only_futures

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/components/my_userList_tile.dart';

import '../components/services/database/database_provider.dart';
import '../models/user.dart';

class FollowListPage extends StatefulWidget {
  const FollowListPage({super.key, required this.uid});
  final String uid;

  @override
  State<FollowListPage> createState() => _FollowListPageState();
}

class _FollowListPageState extends State<FollowListPage> {
  //Provider
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
//
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  @override
  void initState() {
    super.initState();
    //load follower list
    loadFollowerList();

    //load following list
    loadFollowingList();
  }

  Future<void> loadFollowerList() async {
    await databaseProvider.loadFollowerProfiles(widget.uid);
  }

  //following
  Future<void> loadFollowingList() async {
    await databaseProvider.loadFollowingProfiles(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    //listen to follower & following
    final followers = listeningProvider.getListOfFollowersProfile(widget.uid);
    final following = listeningProvider.getListOfFollowingProfile(widget.uid);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          bottom: TabBar(
            dividerColor: Colors.transparent,
            padding: const EdgeInsets.all(4),
            labelPadding: const EdgeInsets.all(8),
            labelColor: Theme.of(context).colorScheme.inversePrimary,
            unselectedLabelColor: Theme.of(context).colorScheme.primary,
            indicatorColor: Theme.of(context).colorScheme.secondary,
            tabs: const [
              //
              Text("Followers"),
              Text("Following"),
            ],
          ),
          foregroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: TabBarView(
          children: [
            _buildUserList(followers, "No followers.."),
            _buildUserList(following, "No following.."),
          ],
        ),
      ),
    );
  }

  //build user list, given a list of profiles
  Widget _buildUserList(List<UserProfile> userList, String emptyMessage) {
    return userList.isEmpty
        ?
        //empty message if there are no users
        Center(
            child: Text(emptyMessage),
          )
        : ListView.builder(
            itemCount: userList.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final user = userList[index]; //get user at current index
              return MyUserListTile(
                user: user,
              );
            });
  }
}
