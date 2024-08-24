// ignore_for_file: avoid_print

/*

DATABASE SERVICE

this class handles all the data from and to firebase

---------
- user profile
- post message
-likes, comments, account stuff (report, block / delete acct)
- follow/unfollow
- search users

*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:twitter_clone/components/services/auth/auth_service.dart';
import 'package:twitter_clone/models/comment.dart';
import 'package:twitter_clone/models/user.dart';

import '../../../models/post.dart';

class DatabaseService {
  //get instance of firebase db & auth
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /*
when user registers, create an account for them but store their details in the database to display on profile page
  USERPROFILE

  */

  //save user info
  Future<void> saveUserInfoinFirebase(
      {required String name, required String email}) async {
    //get current uid
    String uid = _auth.currentUser!.uid;

    //extract username from email
    String username = email.split('@')[0];

    //create user profile
    UserProfile user = UserProfile(
        uid: uid, name: name, username: username, email: email, bio: "");

    //convert user tinto a map so we can store in firebase
    final userMap = user.toMap();

    //save user info in firebase
    await _db.collection("Users").doc(uid).set(userMap);
  }

  //get user info
  Future<UserProfile?> getUserFromFirebase(String uid) async {
    try {
      //retrieve user doc from firebase
      DocumentSnapshot userDoc = await _db.collection("Users").doc(uid).get();

      //convert doc to user profile
      return UserProfile.fromDocument(userDoc);
    } catch (e) {
      print(e);
      return null;
    }
  }

  //update bio
  Future<UserProfile?> updateUserBioFromFirebase(String bio) async {
    //get current uid
    String uid = AuthService().getCurrentUid();

    //attempt to update in firebase
    try {
      await _db.collection("Users").doc(uid).update({'bio': bio});

      //convert doc to user profile
      // return UserProfile.fromDocument(userDoc);
    } catch (e) {
      print(e);
      // return null;
    }
    return null;
  }

  //Delete User Info
  Future<void> deleteUserInfoFromFireBase(String uid) async {
    WriteBatch batch = _db.batch();

    //delete user doc
    DocumentReference userDoc = _db.collection("Users").doc(uid);
    batch.delete(userDoc);

    //delete user posts
    QuerySnapshot userPosts =
        await _db.collection("Posts").where('uid', isEqualTo: uid).get();

    for (var post in userPosts.docs) {
      batch.delete(post.reference);
    }

    //delete user comments
    QuerySnapshot userComments =
        await _db.collection("Comments").where('uid', isEqualTo: uid).get();
    for (var comment in userComments.docs) {
      batch.delete(comment.reference);
    }

    //delete likes done by this user
    QuerySnapshot allPosts = await _db.collection("Posts").get();

    for (QueryDocumentSnapshot post in allPosts.docs) {
      Map<String, dynamic> postData = post.data() as Map<String, dynamic>;
      var likedBy = postData['likedBy'] as List<dynamic>? ?? [];
      // batch.delete(like.reference);
      if (likedBy.contains(uid)) {
        batch.update(post.reference, {
          'likedBy': FieldValue.arrayRemove([uid]),
          'likes': FieldValue.increment(-1),
        });
      }
    }

    //commit batch
    await batch.commit();
  }

  /*
   POST MESSAGE
  
*/
//post a message
  Future<void> postMessageinFireBase(String message) async {
    try {
      String uid = _auth.currentUser!.uid;

      //use uid to get user's profile
      UserProfile? user = await getUserFromFirebase(uid);

      //create a new post
      Post newPost = Post(
        id: '',
        uid: uid,
        name: user!.name,
        username: user.username,
        message: message,
        timestamp: Timestamp.now(),
        likeCount: 0,
        likedBy: [],
      );

      //convert object to a map
      Map<String, dynamic> newPostMap = newPost.toMap();

      //add to FireStore
      await _db.collection("Posts").add(newPostMap);
    } catch (e) {
      print(e);
    }
  }

//delete a post

  Future<void> deletePostFromFirebase(String postID) async {
    try {
      await _db.collection("Posts").doc(postID).delete();
    } catch (e) {
      print(e.toString());
    }
  }

//get all posts
  Future<List<Post>> getAllPostsfromFireBase() async {
    try {
      QuerySnapshot snapshot = await _db
          //goto collection Posts
          .collection("Posts")
          //ararnge
          .orderBy('timestamp', descending: true)
          //get data
          .get();
      return snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

//get individual post

/*

  */

  /*
   LIKES
  */
  Future<void> toggleLikeinFireBase(String postID) async {
    try {
      //get curretn user id
      String uid = _auth.currentUser!.uid;
      //goto doc for this post
      DocumentReference postDoc = _db.collection("Posts").doc(postID);

      //execute like
      await _db.runTransaction((transaction) async {
        //get post data
        DocumentSnapshot postsnapShot = await transaction.get(postDoc);

        //
        //get like of users
        List<String> likedBy = List<String>.from(postsnapShot['likedBy'] ?? []);

        //get like count
        int currentCountLike = postsnapShot["likes"];

        //if usr has not liked post - > then like
        if (!likedBy.contains(uid)) {
          likedBy.add(uid);

          currentCountLike++;
        }

        //if usr has liked post -. then unlike
        else {
          likedBy.remove(uid);
          currentCountLike--;
        }

        //update
        transaction
            .update(postDoc, {'likes': currentCountLike, 'likedBy': likedBy});
      });
    } catch (e) {
      print(e);
    }
  }

  /*
   COMMENTS
  */

  //add a comment
  Future<void> addCommenToFirebase(String postId, message) async {
    try {
      //get current user
      String uid = _auth.currentUser!.uid;
      UserProfile? user = await getUserFromFirebase(uid);

      //create a new section- Comment
      Comment newComment = Comment(
          id: '',
          username: user!.username,
          name: user!.name,
          message: message,
          timestamp: Timestamp.now(),
          postID: postId,
          uid: uid);

      //convet to map
      Map<String, dynamic> newCommentMap = newComment.toMap();

      //to store in firstore
      await _db.collection('Comments').add(newCommentMap);

      //to store
    } catch (e) {
      print(e);
    }
  }

  //delete comment

  Future<void> deleteCommentFromFirebase(String commentID) async {
    try {
      await _db.collection("Comments").doc(commentID).delete();
    } catch (e) {
      print(e.toString());
    }
  }

  //fetch comments for a post
  Future<List<Comment>> getCommentFromFirebase(String postID) async {
    try {
      // await _db.collection("Comments").where(postID).delete();
      QuerySnapshot snapshot = await _db
          .collection('Comments')
          .where('postId', isEqualTo: postID)
          .get();

      //return as a list of comments
      return snapshot.docs.map((doc) => Comment.fromDocument(doc)).toList();
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  /*

  Account Stuff

  */
//REPORT Post
  Future<void> reportUserinFirebase(String postId, userId) async {
    //get current userId
    final currentUserId = _auth.currentUser!.uid;

    //craete a report map

    final report = {
      "reportedBy": currentUserId,
      "messageId": postId,
      "messageOwnerId": userId,
      "timestamp": FieldValue.serverTimestamp(),
    };

    //update in firestore
    await _db.collection("Reports").add(report);
  }

  //Block USER
  Future<void> blockUserinFireBase(String userId) async {
    //get current userId
    final currentUserId = _auth.currentUser!.uid;

    //add this user to blocked list

    await _db
        .collection("Users")
        .doc(currentUserId)
        .collection("BlockedUsers")
        .doc(userId)
        .set({});
  }

  //UNBLOCK USER

  Future<void> unblockUserFromFirebase(String blockUserId) async {
    //get current userId
    final currentUserId = _auth.currentUser!.uid;

    //unblock in firebase
    await _db
        .collection("Users")
        .doc(currentUserId)
        .collection("BlockedUsers")
        .doc(blockUserId)
        .delete();
  }

  //Get list of bloacked user ids

  Future<List<String>> getBlockedUidsFromFirebase() async {
    //get current userId
    final currentUserId = _auth.currentUser!.uid;

    //get data of blocked users
    final snapshot = await _db
        .collection("Users")
        .doc(currentUserId)
        .collection("BlockedUsers")
        .get();

    //return as a list of uids

    return snapshot.docs.map((doc) => doc.id).toList();
  }

  /*
  FOLLOW

  */

  //FOLOW USER
  Future<void> followUserInFireBase(String uid) async {
    //get current logged in user
    final currentUserId = _auth.currentUser!.uid;

    //add this user to following list
    await _db
        .collection("Users")
        .doc(currentUserId)
        .collection("Following")
        .doc(uid)
        .set({});

    //add current user to the target user's followers
    await _db
        .collection("Users")
        .doc(uid)
        .collection("Followers")
        .doc(currentUserId)
        .set({});
  }

  //UNFOLLOW user
  Future<void> unfollowUserFromFirebase(String uid) async {
    //get current logged in user
    final currentUserId = _auth.currentUser!.uid;

    //remove this user from following list
    await _db
        .collection("Users")
        .doc(currentUserId)
        .collection("Following")
        .doc(uid)
        .delete();

    //remove current user from the target user's followers
    await _db
        .collection("Users")
        .doc(uid)
        .collection("Followers")
        .doc(currentUserId)
        .delete();
  }

  //GET list of user's follower: list of uids

  Future<List<String>> getFollowerUidsFromFirebase(String uid) async {
    //get the followers from firebase
    final snapshot =
        await _db.collection("Users").doc(uid).collection("Followers").get();

    //return as a simple list of uids
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  //GET list of user's following: list of uids
  Future<List<String>> getFollowingUidsFromFirebase(String uid) async {
    //get the following from firebase
    final snapshot =
        await _db.collection("Users").doc(uid).collection("Following").get();

    //return as a simple list of uids
    return snapshot.docs.map((doc) => doc.id).toList();
  }

//
/*
SEARCH 
*/
//search for users by name
  Future<List<UserProfile>> searchUserInFirebase(String query) async {
    try {
      //get the data from firebase
      final snapshot = await _db
          .collection("Users")
          .where("username", isGreaterThanOrEqualTo: query)
          .where('username', isLessThanOrEqualTo: "$query\uf8ff")
          .get();

      //return as a list of users
      return snapshot.docs.map((doc) => UserProfile.fromDocument(doc)).toList();
    } catch (e) {
      print(e.toString());
      return [];
    }
  }
}
