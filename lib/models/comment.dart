import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String postID;
  final String uid;
  final String name;
  final String username;
  final String message;
  final Timestamp timestamp;

  Comment({
    required this.id,
    required this.postID,
    required this.uid,
    required this.name,
    required this.username,
    required this.message,
    required this.timestamp,
  });

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
        id: doc.id,
        postID: doc['postId'],
        uid: doc['uid'],
        name: doc['name'],
        username: doc['username'],
        message: doc['message'],
        timestamp: doc['timestamp']);
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postID,
      'uid': uid,
      'name': name,
      'username': username,
      'message': message,
      'timestamp': timestamp,
    };
  }
}
