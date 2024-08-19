/*

USER PROFILE


-uid
-emial
-username, bio, profile photo
*/

import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String name;
  final String username;
  final String email;
  final String bio;

  UserProfile({
    required this.uid,
    required this.name,
    required this.username,
    required this.email,
    required this.bio,
  });

  /*

  //convert firestore doc to a user profile(to use in the app)

  */

  factory UserProfile.fromDocument(DocumentSnapshot doc) {
    return UserProfile(
        uid: doc['uid'],
        name: doc['name'],
        username: doc['username'],
        email: doc['email'],
        bio: doc['bio']);
  }

  /*

  //convert userprofile to map(so to store in firebase)

  */
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'username': username,
      'bio': bio,
    };
  }
}
