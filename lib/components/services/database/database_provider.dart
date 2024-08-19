//this provider is used to separate the firestore data handling and the UI of our app

// -- the data base service class handles data to and from firebase
//--- the data base provider class processes the data to display in our app

import 'package:flutter/material.dart';
import 'package:twitter_clone/components/services/auth/auth_service.dart';
import 'package:twitter_clone/components/services/database/database_service.dart';
import 'package:twitter_clone/models/comment.dart';

import '../../../models/post.dart';
import '../../../models/user.dart';

class DatabaseProvider extends ChangeNotifier {
  //get db and auth
  final _auth = AuthService();
  final _db = DatabaseService();

  //get user profile given ui

  Future<UserProfile?> userProfile(String uid) => _db.getUserFromFirebase(uid);

  //update user bio
  Future<UserProfile?> updateBio(String bio) =>
      _db.updateUserBioFromFirebase(bio);

  //local of posts
  List<Post> _allPosts = [];

  // get posts
  List<Post> get allPosts => _allPosts;

  //post Message
  Future<void> postMessage(String message) async {
    // post message in firebase
    await _db.postMessageinFireBase(message);

    //reload data from firebase
    await loadAllPost();
  }

  //fetch all posts
  Future<void> loadAllPost() async {
    //get all posts from firebase
    final allPosts = await _db.getAllPostsfromFireBase();

    _allPosts = allPosts;

    //initializee like data
    initializeLikeMap();

    //update UI
    notifyListeners();
  }

  //
  List<Post> filterUserPosts(String uid) {
    return _allPosts.where((post) => post.uid == uid).toList();
  }

  //delete post
  Future<void> deletePost(String postID) async {
    //delete from firebase
    await _db.deletePostFromFirebase(postID);

    //reload data from firebase
    await loadAllPost();
  }

  //likes
//local map to track like count
  Map<String, int> _likeCounts = {
    //for each post id: like count
  };

//local list to track liked by current user
  List<String> _likedPosts = [];

  //does current user like this post?
  bool isPostByCurrentUser(String postID) => _likedPosts.contains(postID);

  //get the like count
  int getLikeCount(String postID) => _likeCounts[postID] ?? 0;

//initialize like map locally

  void initializeLikeMap() {
    //get current uid
    final currentUserID = _auth.getCurrentUid();

    //clear liked post for when new user signs in, clear local data
    _likedPosts.clear();

    //for each post get like data
    for (var post in _allPosts) {
      //update like count map
      _likeCounts[post.id] = post.likeCount;

      // if the current user already likes this post
      if (post.likedBy.contains(currentUserID)) {
        //add this post id to local list of liked posts
        _likedPosts.add(post.id);
      }
    }
  }

  //toggle like
  Future<void> toggleLike(String postID) async {
    //store original value in case it fails
    final likedPostOrijinal = _likedPosts;
    final likedCountsOrijin = _likeCounts;

    //oerform like/unlike
    if (_likedPosts.contains(postID)) {
      _likedPosts.remove(postID);
      _likeCounts[postID] = (_likeCounts[postID] ?? 0) - 1;
    } else {
      _likedPosts.add(postID);
      _likeCounts[postID] = (_likeCounts[postID] ?? 0) + 1;
    }

    //update UI
    notifyListeners();

    //now lets update in our database

    try {
      //atempt like in database
      await _db.toggleLikeinFireBase(postID);
    } catch (e) {
      _likedPosts = likedPostOrijinal;
      _likeCounts = likedCountsOrijin;
      print(e);

      // update ui
      notifyListeners();
    }
  }

  //COMMENTs

  // {
  //   //get all comments for a post
  // postId1 : [comment 1, comment2, ...],
  // postId2 : [comment 1, comment2, ...],
  // postId3 : [comment 1, comment2, ...],
  // }

  //local list of comments
  final Map<String, List<Comment>> _comments = {};

  //get all comments locally
  List<Comment> getComments(String postId) => _comments[postId] ?? [];

  //fetch comments from db for a post
  Future<void> loadComments(String postId) async {
    //get all comments for this post
    final allComments = await _db.getCommentFromFirebase(postId);

    //update local data

    _comments[postId] = allComments;

    //update UI
    notifyListeners();
  }

  // add a comment
  Future<void> addComment(String postId, message) async {
    // add comments in firebase
    await _db.addCommenToFirebase(postId, message);

    //reload comments
    await loadComments(postId);
  }

  //delete a comment
  Future<void> deleteComment(String commentId, postId) async {
    // delete comment in firebase
    await _db.deleteCommentFromFirebase(commentId);

    //reload comments
    await loadComments(postId);
  }

  /*
ACCOUNT STUFF
  */

  //local list of blocked USers
  List<UserProfile> _blockedUsers = [];

  //get list of blocked Users

  List<UserProfile> get blockedUsers => _blockedUsers;

  //fetch blocked user
  Future<void> loadBlockedUsers() async {
    //get list of blocked user ids
    final blockeduserIds = await _db.getBlockedUidsFromFirebase();

    //get full user details using uids
    final blockedUserData = await Future.wait(
        blockeduserIds.map((id) => _db.getUserFromFirebase(id)));

    // return as a list
    _blockedUsers = blockedUserData.whereType<UserProfile>().toList();

    //update UI
    notifyListeners();
  }

  //block user
  Future<void> blockUser(String userId) async {
    //perform block in firebase
    await _db.blockUserinFireBase(userId);

    //reload blocked users
    await loadBlockedUsers();

    //reload data
    await loadAllPost();

    //update UI
    notifyListeners();
  }

  //unblock user
  Future<void> unblockUser(String blockedUserId) async {
    //perform unblock in firebase
    await _db.unblockUserFromFirebase(blockedUserId);

    //reload blocked users
    await loadBlockedUsers();

    //reload data
    await loadAllPost();

    //update UI
    notifyListeners();
  }

  //report user and post
  Future<void> reportUser(String postId, userId) async {
    await _db.reportUserinFirebase(postId, userId);
  }
}
