import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String uid;
  final String name;
  final String username;
  final String message;
  final Timestamp timestamp;
  final int likeCount;
  final List<String> likedBy;

  Post(
      {required this.id,
      required this.uid,
      required this.name,
      required this.username,
      required this.timestamp,
      required this.likeCount,
      required this.likedBy,
      required this.message});

  //convert a firestore doc to a post object
  //convert firestore doc to a user profile(to use in the app)

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      id: doc.id,
      uid: doc['uid'],
      name: doc['name'],
      username: doc['username'],
      message: doc['message'],
      timestamp: doc['timestamp'],
      likeCount: doc['likes'],
      likedBy: List<String>.from(doc['likedBy'] ?? []),
    );
  }

  /*

  //convert Post to map(so to store in firebase)

  */
  Map<String, dynamic> toMap() {
    return {
      // 'id': id,
      'uid': uid,
      'name': name,
      'username': username,
      'message': message,
      'timestamp': timestamp,
      'likes': likeCount,
      'likedBy': likedBy,
    };
  }

  //convert post object to store in firebase
}
