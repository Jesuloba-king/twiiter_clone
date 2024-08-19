import 'package:flutter/material.dart';
import 'package:twitter_clone/models/post.dart';
import 'package:twitter_clone/pages/post_page.dart';
import 'package:twitter_clone/pages/profile.dart';

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
