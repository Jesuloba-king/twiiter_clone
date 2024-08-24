import 'package:flutter/material.dart';

class MyProfileStat extends StatelessWidget {
  const MyProfileStat(
      {super.key,
      required this.postCount,
      required this.followerCount,
      required this.followingCount,
      required this.onUserTap});

  final int followerCount, followingCount, postCount;
  final void Function() onUserTap;

  @override
  Widget build(BuildContext context) {
    //textStyle for Coun
    var textStleForCount = TextStyle(
      fontSize: 20,
      color: Theme.of(context).colorScheme.inversePrimary,
    );

    //style for text
    var textStleForTextt = TextStyle(
      color: Theme.of(context).colorScheme.primary,
    );
    return GestureDetector(
      onTap: onUserTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //posts
          SizedBox(
            width: 100,
            child: Column(
              children: [
                Text("$postCount", style: textStleForCount),
                Text('Posts', style: textStleForTextt),
              ],
            ),
          ),

          //followers
          SizedBox(
            width: 100,
            child: Column(
              children: [
                Text('$followerCount', style: textStleForCount),
                Text('Followers', style: textStleForTextt),
              ],
            ),
          ),

          //following
          SizedBox(
            width: 100,
            child: Column(
              children: [
                Text('$followingCount', style: textStleForCount),
                Text('Following', style: textStleForTextt),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
