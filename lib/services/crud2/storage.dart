import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:testapp/services/crud/crud_exceptions.dart';
import 'package:testapp/models/post.dart';
import 'package:uuid/uuid.dart';

final FirebaseStorage _storage = FirebaseStorage.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class StorageService {
  Future<String> uploadFileToStorage(
      String username, String childName, Uint8List file) async {
    Reference ref = _storage.ref().child(childName).child(username);
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snapshot = await uploadTask;
    String url = await snapshot.ref.getDownloadURL();
    return url;
  }

  Future<String> saveData({
    required String username,
    required String datatype,
    required Uint8List file,
  }) async {
    String resp = "Some error occurred while saving";
    try {
      if (username.isNotEmpty || datatype.isNotEmpty) {
        String imageUrl = await uploadFileToStorage(username, datatype, file);
        if (datatype == "profilePicture") {
          // Update profile picture
          DocumentReference docRef = FirebaseFirestore.instance
              .collection('userProfile')
              .doc(username); // Use username as document ID

          await docRef.set({
            'username': username,
            'datatype': datatype,
            'url': imageUrl,
          }, SetOptions(merge: true)); // Merge data if document already exists

          resp = "The profile picture was saved successfully";
        } else if (datatype == "banner") {
          // Update banner image
          DocumentReference docRef = FirebaseFirestore.instance
              .collection('userProfile')
              .doc(username); // Use username as document ID

          await docRef.set({
            'banner': datatype,
            'bannerurl': imageUrl,
          }, SetOptions(merge: true)); // Merge data if document already exists

          resp = "The banner image was saved successfully";
        }
      }
    } catch (e) {
      resp = e.toString();
    }
    return resp;
  }

  Future<String> uploadPostToStorage(
      String username, String childName, Uint8List file, bool isPost) async {
    // creating location to our firebase storage

    Reference ref = _storage.ref().child(childName).child(username);
    if (isPost) {
      String id = const Uuid().v1();
      ref = ref.child(id);
    }

    // putting in uint8list format -> Upload task like a future but not future
    UploadTask uploadTask = ref.putData(file);

    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> uploadPost({
    required String datatype,
    required String collectionName,
    required String username,
    required Uint8List file,
    required String description,
  }) async {
    String res = "Some error occurred";
    try {
      String postUrl =
          await uploadPostToStorage(username, collectionName, file, true);
      String postId = const Uuid().v1(); // creates unique id based on time
      Post post = Post(
        postId: postId,
        username: username,
        postUrl: postUrl,
        datatype: datatype,
        collectionName: collectionName,
        description: description,
        likes: 0, // Initialize likes to 0
        createdAt: DateTime.now(),
      );
      _firestore.collection(collectionName).doc(postId).set(post.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  final CollectionReference profile =
      FirebaseFirestore.instance.collection('userProfile');

  Future<String> getUrlfield(String username, String fieldName) async {
    /* final user = AuthService.firebase().currentUser; */
    final querySnapshot =
        await profile.where('username', isEqualTo: username).get();
    if (querySnapshot.docs.isNotEmpty) {
      final userData = querySnapshot.docs.first.data();
      final fieldValue =
          (userData as Map<String, dynamic>)[fieldName]?.toString() ?? '';
      return fieldValue;
    } else {
      throw UserNotFoundException();
    }
  }
}
