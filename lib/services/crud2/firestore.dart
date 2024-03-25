import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testapp/services/auth/auth_service.dart';
import 'package:testapp/services/crud/crud_exceptions.dart';

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

  // Read
  /*Stream<QuerySnapshot> getUsersStream() {
    final usersStream = users.orderBy('date_registered', descending: true).snapshots();
    return usersStream;
  }*/

/*
  Future<void> updateNote(String docID, String newnote) {
    return notes.doc(docID).update({
      'note': newnote,
      'date': Timestamp.now(),
    });
  }

  // Delete
  Future<void> deleteNote(String docID, String newnote) {
    return notes.doc(docID).delete();
  } */
}
