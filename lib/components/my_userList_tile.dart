import 'package:flutter/material.dart';
import 'package:twitter_clone/models/user.dart';
import 'package:twitter_clone/pages/profile.dart';

class MyUserListTile extends StatelessWidget {
  const MyUserListTile({super.key, required this.user});

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        title: Text(user.username),
        subtitle: Text("@${user.username}"),
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
        subtitleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.primary,
        ),
        leading: Icon(
          Icons.person,
          color: Theme.of(context).colorScheme.primary,
        ),
        // leading: CircleAvatar(
        //   radius: 20,
        //   backgroundImage: NetworkImage(user.profile_image_url),
        // ),
        trailing: Icon(
          Icons.arrow_forward,
          color: Theme.of(context).colorScheme.primary,
        ),
        onTap: () {
          // Implement onTap action here
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return ProfilePage(uid: user.uid);
          }));
        },
      ),
    );
  }
}
