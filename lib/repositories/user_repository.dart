import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ticketapp/model/organizer.dart';
import 'package:ticketapp/model/promoter.dart';
import 'package:ticketapp/model/user.dart';
import 'package:ticketapp/services/firebase.dart';

class UserRepository {
  static UserRepository _instance;

  static UserRepository get instance {
    if (_instance == null) {
      _instance = UserRepository._();
    }
    return _instance;
  }

  UserRepository._();

  dispose() {
    currentUserNotifier.value = null;
    _instance = null;
  }

  ValueNotifier<User> currentUserNotifier = ValueNotifier<User>(null);

  User currentUser() {
    return currentUserNotifier.value;
  }

  bool get isLoggedIn => currentUser() != null;

  Future<User> createUser(String email, String password, String firstName, String lastName, DateTime dob, Gender gender,
      {String uid}) async {
    print(uid);
    String id = await FBServices.instance.createNewUser(email, password, firstName, lastName, dob, gender, uid);
    if (id == null) {
      return null;
    } else {
      currentUserNotifier.value = User()
        ..firebaseUserID = id
        ..firstname = firstName
        ..lastname = lastName
        ..email = email
        ..dob = dob
        ..gender = gender ?? Gender.Unknown;
      return currentUserNotifier.value;
    }
  }

  /// Retrieve user data from the database
  Future<User> getUser(uid) async {
    currentUserNotifier.value = null;
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (!userSnapshot.exists) {
      return null;
    } else {
      currentUserNotifier.value = User()
        ..firebaseUserID = userSnapshot.id
        ..firstname = userSnapshot.data()["firstname"]
        ..lastname = userSnapshot.data()["lastname"]
        ..email = userSnapshot.data()["email"]
        ..dob = userSnapshot.data().containsKey("dob")
            ? DateTime.fromMillisecondsSinceEpoch(userSnapshot.data()["dob"].millisecondsSinceEpoch)
            : null
        ..profileImageURL = userSnapshot.data().containsKey("profileimage") ? userSnapshot.data()["profileimage"] : ""
        ..phone = userSnapshot.data()["phone"]
        ..role = userSnapshot.data()["role"];
      try {
        currentUserNotifier.value.gender =
            Gender.values.firstWhere((element) => element.toDBString() == userSnapshot.data()["gender"]);
      } catch (_) {
        try {
          currentUserNotifier.value.gender = Gender.values[userSnapshot.data()["gender"]];
        } catch (_) {
          currentUserNotifier.value.gender = Gender.Unknown;
        }
      }

      return currentUserNotifier.value;
    }
  }

  Future<Organizer> loadOrganizer(String uid) async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('organizers').doc(uid).get();
    return Organizer.fromMap(userSnapshot.id, userSnapshot.data());
  }

  Future<Promoter> loadPromoter(String uid) async {
    DocumentSnapshot promoterSnapshot = await FirebaseFirestore.instance.collection('promoters').doc(uid).get();
    if (promoterSnapshot.exists) {
      return Promoter.fromMap(promoterSnapshot.id, promoterSnapshot.data());
    } else {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      return Promoter.fromMap(userSnapshot.id, userSnapshot.data());
    }
  }
}
