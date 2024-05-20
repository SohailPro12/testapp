import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:testapp/services/auth/auth_service.dart';
import 'package:testapp/services/crud/crud_exceptions.dart';
import 'package:testapp/models/post.dart';

class UserData {
  final String username;
  final String email;
  final DateTime birthDate;
  final Timestamp dateRegistered;
  final String fullName;
  final String phoneNumber;
  final String gender;
  final String country;
  final String favoriteSport;
  final String level;
  final String type;

  UserData({
    required this.username,
    required this.email,
    required this.birthDate,
    required this.dateRegistered,
    required this.fullName,
    required this.phoneNumber,
    required this.gender,
    required this.country,
    required this.favoriteSport,
    required this.level,
    required this.type,
  });
}

class FireStoreService {
  //get table(collection) of notes
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  // Create
  Future<void> addUser(
      String username, String email, DateTime birthDate) async {
    // Check if the username already exists
    final existingUser = await users.doc(username).get();
    if (existingUser.exists) {
      throw UsernameAlreadyExistsException("Email already exists");
    }

    // If username is unique, add the user
    return users.doc(username).set({
      'username': username,
      'email': email,
      'birth_date': birthDate,
      'date_registered': Timestamp.now(),
    });
  }

  Future<void> addAdditionalInfoUser(
      String username,
      String fullName,
      String phoneNumber,
      String gender,
      String country,
      String favoriteSport,
      String level,
      String type) {
    return users.doc(username).update({
      'full_name': fullName,
      'phone_number': phoneNumber,
      'gender': gender,
      'country': country,
      'favorite_sport': favoriteSport,
      'level': level,
      'type': type,
    });
  }

  //Coach more information
  Future<void> coachAdditionalInfoUser(
      String username,
      String yearsOfexperience,
      String domain,
      String availability,
      String website,
      String bio) {
    return users.doc(username).update({
      'Years Of Experience': yearsOfexperience,
      'Domain': domain,
      'Availability': availability,
      'Website': website,
      'Bio': bio,
    });
  }

  Future<String> getUserType(String email) async {
    final querySnapshot = await users.where('email', isEqualTo: email).get();
    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first['type'];
    } else {
      return "uknown";
    }
  }

  Future<Map<String, dynamic>> getUserData(String email) async {
    final querySnapshot = await users.where('email', isEqualTo: email).get();
    if (querySnapshot.docs.isNotEmpty) {
      final userData = querySnapshot.docs.first.data()
          as Map<String, dynamic>; // Explicit cast
      return userData;
    } else {
      throw "Unknown";
    }
  }

  Future<String> getUserField(String fieldName) async {
    final user = AuthService.firebase().currentUser;
    final querySnapshot =
        await users.where('email', isEqualTo: user!.email).get();
    if (querySnapshot.docs.isNotEmpty) {
      final userData = querySnapshot.docs.first.data();
      final fieldValue =
          (userData as Map<String, dynamic>)[fieldName]?.toString() ?? '';
      return fieldValue;
    } else {
      throw UserNotFoundException();
    }
  }

  Future<String> getUserFieldByUsername(
      String fieldName, String username) async {
    final querySnapshot =
        await users.where('username', isEqualTo: username).get();
    if (querySnapshot.docs.isNotEmpty) {
      final userData = querySnapshot.docs.first.data();
      final fieldValue =
          (userData as Map<String, dynamic>)[fieldName]?.toString() ?? '';
      return fieldValue;
    } else {
      throw UserNotFoundException();
    }
  }

//update
  Future<void> updateUserField(
      String username, String fieldName, String value) async {
    final user = AuthService.firebase().currentUser;
    if (user == null) {
      throw UserNotFoundException();
    }
    await users.doc(username).update({
      fieldName: value,
    });
  }

  Future<void> updateUserPhoto(String username, Uint8List photo) async {
    final userDoc = users.doc(username);
    await userDoc.set({'profile_photo': photo}, SetOptions(merge: true));
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Post>> getAllPosts(String username) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('HubPosts')
          .where('username', isEqualTo: username)
          .get();

      List<Post> posts = querySnapshot.docs
          .map((doc) {
            return Post(
              postId: doc.id,
              description: doc['description'],
              postUrl: doc['postUrl'],
              datatype: doc['datatype'],
              username: doc['username'],
              likes: doc['likes'],
              createdAt: doc['createdAt']?.toDate(),
              collectionName: doc['collectionName'],
              // Add more fields if needed
            );
          })
          .where((post) => !post.description.contains('premium'))
          .toList();

      return posts;
    } catch (e) {
      return [];
    }
  }

  Future<List<Post>> getPremiumPosts(String username) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('HubPosts')
          .where('username', isEqualTo: username)
          .get();

      List<Post> premiumPosts = querySnapshot.docs
          .map((doc) => Post.fromSnap(doc))
          .where((post) => post.description.contains('premium'))
          .toList();

      return premiumPosts;
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching premium posts: $e');
      return [];
    }
  }

  Future getFieldByUsernameCollection(
      String field, String username, String collection) async {
    try {
      final querySnapshot = await _firestore
          .collection(collection)
          .where('username', isEqualTo: username)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data();
        final fieldValue = (userData)[field];
        return fieldValue;
      } else {
        throw UserNotFoundException();
      }
    } catch (e) {
      return null;
    }
  }

  updateUserMetrics(String username, String weight, String height) {
    return users.doc(username).update({
      'weight': weight,
      'height': height,
    });
  }

  Future<void> deleteUser(String username) async {
    try {
      final FirebaseAuth _auth = FirebaseAuth.instance;
      // Delete the user's authentication account from Firebase Authentication
      User? user = _auth.currentUser;
      if (user != null) {
        await user.delete();
      }

      // Delete the user document from the "users" collection
      await users.doc(username).delete();

      // Delete the user document from the "userProfile" collection
      await _firestore.collection('userProfile').doc(username).delete();

      // Handle any additional data deletion if necessary
    } catch (e) {
      // Handle errors or exceptions
      print('Error deleting user: $e');
      throw e; // Rethrow the exception to propagate it upwards
    }
  }
}
