// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/components/my_post_tile.dart';
import 'package:twitter_clone/components/my_profile_stat.dart';
import 'package:twitter_clone/components/my_textfiled.dart';
import 'package:twitter_clone/components/services/auth/auth_service.dart';
import 'package:twitter_clone/components/services/database/database_provider.dart';
import 'package:twitter_clone/models/user.dart';

import '../components/my_bio_box.dart';
import '../components/my_follow_button.dart';
import '../helper/navigate_pages.dart';
import 'follow_list_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.uid});

  final String uid;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController editController = TextEditingController();

  //
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
//
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  //user info
  UserProfile? userProfile;

  String currentUserId = AuthService().getCurrentUid();

  bool _isLoading = false;
  bool isFollow = false;

  //

  @override
  void initState() {
    loadUser();
    super.initState();
  }

  Future<void> toggleFollow() async {
    if (isFollow) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Unfollow"),
              content: const Text("Are you sure you want to unfollow?"),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),

                //delete button
                TextButton(
                  child: const Text("Yes"),
                  onPressed: () async {
                    //close dialog

                    Navigator.pop(context);

                    //handle follow action
                    await databaseProvider.unfollowUser(widget.uid);

                    // //ley user know...
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //     const SnackBar(content: Text("Account Unfollowed!")));
                  },
                ),
              ],
            );
          });
    } else {
      await databaseProvider.followUser(widget.uid);
    }
  }

  Future<void> loadUser() async {
    userProfile = await databaseProvider.userProfile(widget.uid);

    //load user's followers and following
    await databaseProvider.loadUsersFollowing(widget.uid);
    await databaseProvider.loadUserFollowers(widget.uid);

    //update following state
    isFollow = databaseProvider.isFollowing(widget.uid);

    setState(() {
      _isLoading = false;
    });
  }

  void _editBioBox() {
    showDialog(
      context: context,
      builder: (context) => MyInputAlertBox(
        textController: editController,
        hintText: "Edit Bio....",
        onPressedText: "Save",
        onPressed: saveBio,
      ),
    );
  }

  //save updated bio
  Future<void> saveBio() async {
    setState(() {
      _isLoading = true;
    });

    //update bio

    await databaseProvider.updateBio(editController.text);

    // reload user

    await loadUser();

    //done loading
    setState(() {
      _isLoading = false;
    });

    print("saving...");
  }

  //
  @override
  Widget build(BuildContext context) {
    //get user posts
    final allUserPosts = listeningProvider.filterUserPosts(widget.uid);
    isFollow = databaseProvider.isFollowing(widget.uid);

    //listen to follower & following
    final followerCount = listeningProvider.getFollowerCount(widget.uid);
    final followingCount = listeningProvider.getFollowingCount(widget.uid);
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          centerTitle: true,
          title: Text(_isLoading ? "" : userProfile?.name ?? ""),
          leading: IconButton(
            onPressed: () => goHomePage(context),
            icon: const Icon(Icons.arrow_back),
          ),
          foregroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: ListView(
          children: [
            //username
            Center(
              child: Text(
                _isLoading ? " " : "@${userProfile?.username ?? ""}",
                style: TextStyle(
                  // fontSize: 25,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            //profile picture

            Center(
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(25)),
                child: Icon(
                  Icons.person,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),

            const SizedBox(
              height: 25,
            ),
            //profile stats
            MyProfileStat(
                onUserTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return FollowListPage(
                      uid: widget.uid,
                    );
                  }));
                },
                postCount: allUserPosts.length,
                followerCount: followerCount,
                followingCount: followingCount),

            const SizedBox(
              height: 25,
            ),

            //follow /unfollow
            if (userProfile != null && userProfile!.uid != currentUserId)
              MyFollowButton(
                onPressed: toggleFollow,
                isFollowing: isFollow,
              ),

            //edit bio
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Bio",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold),
                  ),
                  if (userProfile != null && userProfile!.uid == currentUserId)
                    GestureDetector(
                      onTap: _editBioBox,
                      child: Icon(
                        Icons.edit,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            //bio box
            MyBioBox(
              text: _isLoading ? "..." : userProfile?.bio ?? "",
            ),

            //posts
            Padding(
              padding: const EdgeInsets.only(left: 25.0, top: 25),
              child: Text(
                "Posts",
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),

            //list of posts from user...
            allUserPosts.isEmpty
                ? const Center(
                    child: Text("No posts yet..."),
                  )
                : ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: allUserPosts.length,
                    itemBuilder: (context, index) {
                      final post = allUserPosts[index];
                      return MyPostTile(
                        post: post,
                        onPostTap: () => goPostPage(context, post),
                        // onUserTap: () => goUserPage(context, post.uid),
                      );
                    }),
          ],
        ));
  }
}
