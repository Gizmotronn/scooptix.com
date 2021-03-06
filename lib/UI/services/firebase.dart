import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:ticketapp/model/user.dart';

import 'bugsnag_wrapper.dart';

class FBServices {
  static FBServices? _instance;

  static FBServices get instance {
    if (_instance == null) {
      _instance = new FBServices._();
    }
    return _instance!;
  }

  FBServices._();

  auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  Future<bool?> isEmailInUse(String email) async {
    if (!email.contains("@") || email.split(".").length < 2) {
      return null;
    }
    try {
      List<String> users = await _auth.fetchSignInMethodsForEmail(email);
      if (users.length < 1) {
        print("not in use");
        return false;
      } else {
        print("in use");
        return true;
      }
    } catch (_) {
      return null;
    }
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<String?> createNewUser(String email, String password, String firstName, String lastName, DateTime dob,
      Gender gender, String? uid) async {
    try {
      if (uid == null) {
        auth.UserCredential authResult = await _auth.createUserWithEmailAndPassword(email: email, password: password);
        auth.User? fbuser = authResult.user;

        await FirebaseFirestore.instance.collection('users').doc(fbuser!.uid).set({
          'firstname': firstName,
          'lastname': lastName,
          'email': email,
          'role': "1",
          'dob': dob,
          'gender': gender.toDBString()
        });

        fbuser.sendEmailVerification();

        return fbuser.uid;
      } else {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'firstname': firstName,
          'lastname': lastName,
          'email': email,
          'role': "1",
          'dob': dob,
          'gender': gender.toDBString()
        });
        return uid;
      }
    } catch (e, s) {
      print("Error during signup");
      print(e);
      BugsnagNotifier.instance.notify("Error during signup \n $e", s, severity: ErrorSeverity.error);
      return null;
    }
  }

  Future<auth.User?> logIn(String email, String password) async {
    try {
      auth.UserCredential authResult = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return authResult.user;
    } catch (e, s) {
      print(e);
      BugsnagNotifier.instance.notify("Error during login \n $e", s, severity: ErrorSeverity.info);
      return null;
    }
  }

  Future<auth.User?> signInWithFacebook(String token) async {
    final auth.AuthCredential credential = auth.FacebookAuthProvider.credential(
      token,
    );
    final auth.User? user = (await _auth.signInWithCredential(credential)).user;

    await user!.getIdToken();

    final auth.User? currentUser = _auth.currentUser;
    return currentUser;
  }
}
