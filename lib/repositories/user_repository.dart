import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ticketapp/model/organizer.dart';
import 'package:ticketapp/model/promoter.dart';
import 'package:ticketapp/model/user.dart';
import 'package:ticketapp/services/firebase.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:ticketapp/services/image_util.dart';

class UserRepository {
  static UserRepository? _instance;

  static UserRepository get instance {
    if (_instance == null) {
      _instance = UserRepository._();
    }
    return _instance!;
  }

  UserRepository._();

  dispose() {
    currentUserNotifier.value = null;
    _instance = null;
  }

  ValueNotifier<User?> currentUserNotifier = ValueNotifier<User?>(null);

  User? currentUser() {
    return currentUserNotifier.value;
  }

  bool get isLoggedIn => currentUser() != null;

  Future<User?> createUser(
      String email, String password, String firstName, String lastName, DateTime dob, Gender gender,
      {String? uid}) async {
    String? id = await FBServices.instance.createNewUser(email, password, firstName, lastName, dob, gender, uid);
    if (id == null) {
      return null;
    } else {
      currentUserNotifier.value = User()
        ..firebaseUserID = id
        ..firstname = firstName
        ..lastname = lastName
        ..email = email
        ..dob = dob
        ..gender = gender;
      return currentUserNotifier.value;
    }
  }

  /// Retrieve user data from the database
  Future<User?> getUser(uid) async {
    currentUserNotifier.value = null;
    DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (!userSnapshot.exists) {
      return null;
    } else {
      currentUserNotifier.value = User()
        ..firebaseUserID = userSnapshot.id
        ..firstname = userSnapshot.get("firstname")
        ..lastname = userSnapshot.get("lastname")
        ..email = userSnapshot.get("email")
        ..dob = userSnapshot.data()!.containsKey("dob")
            ? DateTime.fromMillisecondsSinceEpoch(userSnapshot.get("dob").millisecondsSinceEpoch)
            : null
        ..profileImageURL = userSnapshot.data()!.containsKey("profileimage") ? userSnapshot.get("profileimage") : ""
        ..phone = userSnapshot.data()!.containsKey("phone") ? userSnapshot.get("phone") : ""
        ..role = userSnapshot.get("role");
      try {
        currentUserNotifier.value!.gender =
            Gender.values.firstWhere((element) => element.toDBString() == userSnapshot.get("gender"));
      } catch (_) {
        try {
          currentUserNotifier.value!.gender = Gender.values[userSnapshot.get("gender")];
        } catch (_) {
          currentUserNotifier.value!.gender = Gender.Unknown;
        }
      }

      return currentUserNotifier.value;
    }
  }

  /// Tries to login a previously logged in user.
  signInCurrentUser() async {
    if (UserRepository.instance.currentUser() == null) {
      auth.User? fbUser = auth.FirebaseAuth.instance.currentUser;
      if (fbUser == null) {
        print("no current user");
        // There seems so be a case where this fails, so just make sure we continue on in that case
        try {
          fbUser = await auth.FirebaseAuth.instance.authStateChanges().first;
        } catch (_) {}
      }
      if (fbUser == null) {
        print("no state change user");
      } else {
        await UserRepository.instance.getUser(fbUser.uid);
      }
    }
  }

  Future<Organizer> loadOrganizer(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await FirebaseFirestore.instance.collection('organizers').doc(uid).get();
    return Organizer.fromMap(userSnapshot.id, userSnapshot.data()!);
  }

  Future<Promoter> loadPromoter(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> promoterSnapshot =
        await FirebaseFirestore.instance.collection('promoters').doc(uid).get();
    if (promoterSnapshot.exists) {
      return Promoter.fromMap(promoterSnapshot.id, promoterSnapshot.data()!);
    } else {
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      return Promoter.fromMap(userSnapshot.id, userSnapshot.data()!);
    }
  }

  Future<void> updateUserProfileImage(Uint8List image) async {
    String url = await ImageUtil.uploadImageToDefaultBucket(
        image, "profiles/${this.currentUser()!.firebaseUserID}/profileimage.png");
    this.currentUser()!.profileImageURL = url;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser()!.firebaseUserID)
        .update({"profileimage": url});
  }
}
