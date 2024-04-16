import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String postId;
  final String username;
  final String postUrl;
  final String datatype;
  final String collectionName;
  final String description;
  final int likes;
  final DateTime createdAt;

  const Post({
    required this.postId,
    required this.username,
    required this.postUrl,
    required this.datatype,
    required this.collectionName,
    required this.description,
    required this.likes,
    required this.createdAt,
  });

  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Post(
      postId: snapshot['postId'],
      username: snapshot['username'],
      postUrl: snapshot['postUrl'],
      datatype: snapshot['datatype'],
      collectionName: snapshot['collectionName'],
      description: snapshot['description'],
      likes: snapshot['likes'],
      createdAt: snapshot['createdAt'] != null
          ? (snapshot['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'postId': postId,
        'username': username,
        'postUrl': postUrl,
        'datatype': datatype,
        'collectionName': collectionName,
        'description': description,
        'likes': likes,
        'createdAt': createdAt,
      };
}
