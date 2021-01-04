import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webapp/model/organizer.dart';
import 'package:webapp/model/promoter.dart';
import 'package:webapp/model/user.dart';
import 'package:webapp/services/firebase.dart';

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
    _instance = null;
  }

  User currentUser;

  Future<User> createUser(String email, String password, String firstName, String lastName, DateTime dob, int gender,
      {String uid}) async {
    String id = await FBServices.instance.createNewUser(email, password, firstName, lastName, dob, gender, uid);
    if (id == null) {
      return null;
    } else {
      currentUser = User()
        ..firebaseUserID = id
        ..firstname = firstName
        ..lastname = lastName
        ..email = email
        ..dob = dob
        ..gender = gender;
      return currentUser;
    }
  }

  /// Retrieve user data from the database
  Future<User> getUser(uid) async {
    currentUser = User();
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (!userSnapshot.exists) {
      return null;
    } else {
      currentUser.firebaseUserID = userSnapshot.id;
      currentUser.firstname = userSnapshot.data()["firstname"];
      currentUser.lastname = userSnapshot.data()["lastname"];
      currentUser.email = userSnapshot.data()["email"];
      currentUser.dob = userSnapshot.data().containsKey("dob")
          ? DateTime.fromMillisecondsSinceEpoch(userSnapshot.data()["dob"].millisecondsSinceEpoch)
          : null;
      currentUser.profileImageURL =
          userSnapshot.data().containsKey("profileimage") ? userSnapshot.data()["profileimage"] : "";
      currentUser.phone = userSnapshot.data()["phone"];
      currentUser.role = userSnapshot.data()["role"];
      currentUser.gender = userSnapshot.data()["gender"];

      return currentUser;
    }
  }

  Future<Organizer> loadOrganizer(String uid) async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('organizers').doc(uid).get();
    return Organizer.fromMap(userSnapshot.id, userSnapshot.data());
  }

  Future<Promoter> loadPromoter(String uid) async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('promoters').doc(uid).get();
    return Promoter.fromMap(userSnapshot.id, userSnapshot.data());
  }
}
