import 'package:flutter/material.dart';
import 'package:twitter_clone/models/post.dart';
import 'package:twitter_clone/pages/post_page.dart';
import 'package:twitter_clone/pages/profile.dart';

import '../pages/account_settings.dart';
import '../pages/blocked-page.dart';
import '../pages/homepage.dart';

void goUserPage(context, String uid) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return ProfilePage(uid: uid);
  }));
}

void goPostPage(context, Post post) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return PostPage(
      post: post,
    );
  }));
}

void gotoBlockPages(context) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return const BlockedUsersPage();
  }));
}

void goAccountSettingspage(context) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return const AccountSettingsPage();
  }));
}

void goHomePage(context) {
  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
    return HomePage();
  }), (route) => route.isFirst);
}
