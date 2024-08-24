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
  List<Post> _followingPost = [];

  // get posts
  List<Post> get allPosts => _allPosts;
  List<Post> get followingPosts => _followingPost;

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

    // get blocked user ids
    final blockedUserIds = await _db.getBlockedUidsFromFirebase();

    //filter out blocked Userd post and update locally
    _allPosts =
        allPosts.where((post) => !blockedUserIds.contains(post.uid)).toList();

    // _allPosts = allPosts;

    //filter out all following post
    loadAllFollowingPost();

    //initializee like data
    initializeLikeMap();

    //update UI
    notifyListeners();
  }

  //load followung piost
  Future<void> loadAllFollowingPost() async {
    //get current userID
    String currentUid = _auth.getCurrentUid();
    // get list of uids that the current logged in user followes from firebase
    final followingUserIds = await _db.getFollowingUidsFromFirebase(currentUid);

    //filter all posts to be the ones for the following tab
    _followingPost =
        _allPosts.where((post) => followingUserIds.contains(post.uid)).toList();

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

  /*
  FOLLOW

  Each user id has a list of :
  -folowers uid
  -following uid

  E.g.
  {
  'uid1' : [ list of uids there are followers/following],
  'uid2' : [ list of uids there are followers/following],
  'uid3' : [ list of uids there are followers/following],
  }
  */

  //local map
  final Map<String, List<String>> _followers = {};
  final Map<String, List<String>> _following = {};
  final Map<String, int> _followerCount = {};
  final Map<String, int> _followingCount = {};

  //get counts for follower & following locally: given a uid
  int getFollowerCount(String uid) => _followerCount[uid] ?? 0;
  int getFollowingCount(String uid) => _followingCount[uid] ?? 0;

  //load followers
  Future<void> loadUserFollowers(String uid) async {
    //get the list of followers uids from firebase
    final listOfFollowerUids = await _db.getFollowerUidsFromFirebase(uid);

    //update local data
    _followers[uid] = listOfFollowerUids;
    _followerCount[uid] = listOfFollowerUids.length;

    //update UI
    notifyListeners();
  }

  //load following
  Future<void> loadUsersFollowing(String uid) async {
    //get follow data from firebase
    final listOfFollowingUids = await _db.getFollowingUidsFromFirebase(uid);

    //update local data
    _following[uid] = listOfFollowingUids;
    _followingCount[uid] = listOfFollowingUids.length;

    //update UI
    notifyListeners();
  }

  //folow user
  Future<void> followUser(String targetUserId) async {
    //get current uid
    final currentUserId = _auth.getCurrentUid();

    //initialize with empty list if null
    _following.putIfAbsent(currentUserId, () => []);
    _followers.putIfAbsent(targetUserId, () => []);

    //optimistic UI changes: update local data & revert back if database request fails
    //follow if current use is not one of the target user's followers
    if (!_followers[targetUserId]!.contains(currentUserId)) {
      //add current user to target user's follower list
      _followers[targetUserId]?.add(currentUserId);

      //update follower count
      _followerCount[targetUserId] = (_followerCount[targetUserId] ?? 0) + 1;

      //then add target user to current user following
      _following[currentUserId]?.add(targetUserId);

      //update following count
      _followingCount[currentUserId] =
          (_followingCount[currentUserId] ?? 0) + 1;
    }

    //update UI
    notifyListeners();

    try {
      //perform follow in firebase //folow user in firebase
      await _db.followUserInFireBase(targetUserId);

      //reload current user's followers
      await loadUserFollowers(currentUserId);

      //reload current user's following
      await loadUsersFollowing(currentUserId);
    } catch (e) {
      //remove current user from target user's followers
      _followers[targetUserId]?.remove(currentUserId);

      //update follower count
      _followerCount[targetUserId] = (_followerCount[targetUserId] ?? 0) - 1;

      //remove from current user following
      _following[currentUserId]?.remove(targetUserId);

      //update following count
      _followingCount[currentUserId] =
          (_followingCount[currentUserId] ?? 0) - 1;

      //update UI
      notifyListeners();

      print(e);
    }
  }

  //unfollow user
  Future<void> unfollowUser(String targetUserId) async {
    //get current uid
    final currentUserId = _auth.getCurrentUid();

    //initialize with empty list if null
    _following.putIfAbsent(currentUserId, () => []);
    _followers.putIfAbsent(targetUserId, () => []);

    //unfollow if current user is one of the target user's following
    if (_followers[targetUserId]!.contains(currentUserId)) {
      //remove current user from target user's following
      _followers[targetUserId]?.remove(currentUserId);

      //update follower count
      _followerCount[targetUserId] = (_followerCount[targetUserId] ?? 1) - 1;

      //remove target user from current user's following list
      _following[currentUserId]?.remove(targetUserId);

      //update the following count
      _followingCount[currentUserId] =
          (_followingCount[currentUserId] ?? 1) - 1;
    }

    //update UI
    notifyListeners();

    try {
      //perform unfollow in firebase
      await _db.unfollowUserFromFirebase(targetUserId);

      //reload user followers
      await loadUserFollowers(currentUserId);

      //reload user following
      await loadUsersFollowing(currentUserId);
    } catch (e) {
      //add current user back into target user's followers
      _followers[targetUserId]?.add(currentUserId);

      //update follower count
      _followerCount[targetUserId] = (_followerCount[targetUserId] ?? 0) + 1;

      //add target user back into current user's following
      _following[currentUserId]?.add(targetUserId);

      //update following count
      _followingCount[currentUserId] =
          (_followingCount[currentUserId] ?? 0) + 1;

      //update UI
      notifyListeners();

      print(e);
    }
  }

  //is current user following target user?

  //get followers for a user locally: given a uid
  List<String> getFollowers(String uid) => _followers[uid] ?? [];

  //get following for a user locally: given a uid
  List<String> getFollowing(String uid) => _following[uid] ?? [];

  // is current user following target user?
  bool isFollowing(String uid) {
    final currentUserId = _auth.getCurrentUid();
    return _followers[uid]?.contains(currentUserId) ?? false;
  }

  /*
MAP OF PROFILES
  */

  final Map<String, List<UserProfile>> _followersProfile = {};
  final Map<String, List<UserProfile>> _followingProfile = {};

  //get list of follower profiles for a given user
  //get followers for a user locally: given a uid
  List<UserProfile> getListOfFollowersProfile(String uid) =>
      _followersProfile[uid] ?? [];

  //get following for a user locally: given a uid
  List<UserProfile> getListOfFollowingProfile(String uid) =>
      _followingProfile[uid] ?? [];

  //load follower profiles for a given uid
  Future<void> loadFollowerProfiles(String uid) async {
    try {
      //get the list of followers uids from firebase
      final followerIds = await _db.getFollowerUidsFromFirebase(uid);

      //craete list of user Profiles
      List<UserProfile> followerProfiles = [];

      //go thru each follower id
      for (String followerId in followerIds) {
        //get user profile from firebase with this uid
        UserProfile? followerProfile =
            await _db.getUserFromFirebase(followerId);

        //addd to follower profile
        if (followerProfile != null) {
          followerProfiles.add(followerProfile);
        }
      }

      //update local data
      _followersProfile[uid] = followerProfiles;

      //update UI
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  //load following profiles for a given uid
  Future<void> loadFollowingProfiles(String uid) async {
    try {
      //get follow data from firebase
      final followingIds = await _db.getFollowingUidsFromFirebase(uid);

      //creat list of following Id
      List<UserProfile> followingProfiles = [];

      //go thru each following id
      for (String followingId in followingIds) {
        //get user profile from firebase with this uid
        UserProfile? followingProfile =
            await _db.getUserFromFirebase(followingId);

        //add to following profile
        if (followingProfile != null) {
          followingProfiles.add(followingProfile);
        } else {
          print('Could not find user with id: $followingId');
        }
      }

      //update local data
      _followingProfile[uid] = followingProfiles;

      //update UI
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

/*
SEARCH USERS
*/

//list of search results
  List<UserProfile> _searchResults = [];

//get list of search results
  List<UserProfile> get searchResults => _searchResults;

  //method for search for users by username
  Future<void> searchUsers(String query) async {
    try {
      //search users in firebase
      final results = await _db.searchUserInFirebase(query.toLowerCase());

      //update local data
      _searchResults = results;

      //update ui
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }
}
