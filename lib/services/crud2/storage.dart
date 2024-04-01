import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:testapp/services/crud/crud_exceptions.dart';

final FirebaseStorage _storage = FirebaseStorage.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class StorageService {
  Future<String> uploadImageToStorage(
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
        String imageUrl = await uploadImageToStorage(username, datatype, file);
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
        } else {
          // For other data types, simply add a new document
          await FirebaseFirestore.instance
              .collection('userProfile')
              .doc(username) // Use username as document ID
              .set({
            'username': username,
            'datatype': datatype,
            'url': imageUrl,
          });

          resp = "The data was saved successfully";
        }
      }
    } catch (e) {
      resp = e.toString();
    }
    return resp;
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
