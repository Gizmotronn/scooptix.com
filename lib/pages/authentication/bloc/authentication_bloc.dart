import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_auth_oauth/firebase_auth_oauth.dart';
import 'package:flutter_facebook_login_web/flutter_facebook_login_web.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:webapp/model/link_type/link_type.dart';
import 'package:webapp/model/user.dart';
import 'package:webapp/repositories/user_repository.dart';
import 'package:webapp/services/firebase.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc(this.linkType) : super(StateInitial());

  final LinkType linkType;
  User user;

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is EventEmailProvided) {
      yield* _checkUserStatus(event.email);
    } else if (event is EventLoginPressed) {
      yield* _loginExistingUser(event.email, event.pw);
    } else if (event is EventCreateNewUser) {
      yield* _createUser(event.email, event.pw, event.firstName, event.lastName, event.dob, event.gender,
          state is StateNewSSOUser ? (state as StateNewSSOUser).uid : null);
    } else if (event is EventChangeEmail) {
      yield StateInitial();
    } else if (event is EventGoogleSignIn) {
      yield* _signInWithGoogle();
    } else if (event is EventFacebookSignIn) {
      yield* _signInWithFacebook();
    } else if (event is EventAppleSignIn) {
      yield* _signInWithApple();
    }
  }

  Stream<AuthenticationState> _checkUserStatus(String email) async* {
    yield StateLoadingUserData();
    bool isInUse = await FBServices.instance.isEmailInUse(email);
    if (isInUse == null) {
      yield StateInvalidEmail();
    } else if (isInUse) {
      yield StateExistingUserEmail();
    } else {
      yield StateNewUserEmail();
    }
  }

  Stream<AuthenticationState> _loginExistingUser(String email, String pw) async* {
    yield StateLoadingLogin();
    auth.User fbuser = await FBServices.instance.logIn(email, pw);
    if (fbuser == null) {
      yield StateLoginFailed();
    } else {
      user = await UserRepository.instance.getUser(fbuser.uid);

      yield StateLoggedIn(email, user.firstname, user.lastname);
    }
  }

  Stream<AuthenticationState> _createUser(
      String email, String pw, String firstName, String lastName, DateTime dob, int gender, String uid) async* {
    if (uid == null && pw.length < 8) {
      // Notify UI about error and revert to previous state
      yield StateErrorSignUp(SignUpError.Password);
      yield StateNewUserEmail();
    } else {
      yield StateLoadingCreateUser();
      user = await UserRepository.instance.createUser(
          email, pw, firstName, lastName, dob, gender >= 0 && gender <= 3 ? Gender.values[gender] : Gender.Unknown,
          uid: uid);
      if (user == null) {
        // Notify UI about error and revert to previous state
        yield StateErrorSignUp(SignUpError.Unknown);
        yield StateNewUserEmail();
      } else {
        yield StateLoggedIn(user.email, user.firstname, user.lastname);
      }
    }
  }

  Stream<AuthenticationState> _signInWithGoogle() async* {
    yield StateLoadingSSO();
    GoogleSignIn _googleSignIn = GoogleSignIn();
    try {
      GoogleSignInAccount gUser = await _googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth = await gUser.authentication;
      final auth.AuthCredential credential = auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      auth.UserCredential authResult = await auth.FirebaseAuth.instance.signInWithCredential(credential);
      auth.User fbUser = authResult.user;
      // If authentication was successful
      if (fbUser != null) {
        this.user = await UserRepository.instance.getUser(fbUser.uid);
        if (user == null) {
          String firstName = fbUser.displayName != null ? fbUser.displayName.split(" ")[0] : "";
          String lastName = fbUser.displayName != null && fbUser.displayName.split(" ").length > 1
              ? fbUser.displayName.split(" ")[1]
              : "";
          yield StateNewSSOUser(gUser.email, fbUser.uid, firstName, lastName);
        } else {
          yield StateLoggedIn(gUser.email, user.firstname, user.lastname);
        }
      } else {
        yield StateErrorSignUp(SignUpError.Unknown);
        yield StateInitial();
      }
    } catch (error) {
      print(error);
      yield StateErrorSignUp(SignUpError.UserCancelled);
      yield StateInitial();
    }
  }

  Stream<AuthenticationState> _signInWithApple() async* {
    yield StateLoadingSSO();
    try {
      auth.User fbUser = await FirebaseAuthOAuth().openSignInFlow("apple.com", ["email"]);
      if (fbUser != null) {
        User user = await UserRepository.instance.getUser(fbUser.uid);
        // New user
        if (user == null) {
          String firstName = fbUser.displayName != null ? fbUser.displayName.split(" ")[0] : "";
          String lastName = fbUser.displayName != null && fbUser.displayName.split(" ").length > 1
              ? fbUser.displayName.split(" ")[1]
              : "";
          yield StateNewSSOUser(fbUser.email, fbUser.uid, firstName, lastName);
        } else {
          // Existing User
          yield StateLoggedIn(fbUser.email, user.firstname, user.lastname);
        }
      } else {
        yield StateErrorSignUp(SignUpError.Unknown);
        yield StateInitial();
      }
    } catch (e) {
      print(e);

      yield StateErrorSignUp(SignUpError.UserCancelled);
      yield StateInitial();
    }
  }

  Stream<AuthenticationState> _signInWithFacebook() async* {
    yield StateLoadingSSO();
    final facebookSignIn = FacebookLoginWeb();
    final FacebookLoginResult result = await facebookSignIn.logIn(['email', 'public_profile']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        auth.User fbUser = await FBServices.instance.signInWithFacebook(result.accessToken.token);
        if (fbUser != null) {
          User user = await UserRepository.instance.getUser(fbUser.uid);
          // New user
          if (user == null) {
            String firstName = fbUser.displayName != null ? fbUser.displayName.split(" ")[0] : "";
            String lastName = fbUser.displayName != null && fbUser.displayName.split(" ").length > 1
                ? fbUser.displayName.split(" ")[1]
                : "";
            yield StateNewSSOUser(fbUser.email, fbUser.uid, firstName, lastName);
          } else {
            // Existing User

            yield StateLoggedIn(fbUser.email, user.firstname, user.lastname);
          }
        } else {
          yield StateErrorSignUp(SignUpError.Unknown);
          yield StateInitial();
        }

        // facebookSignIn.testApi();
        break;
      case FacebookLoginStatus.cancelledByUser:
        print('Login cancelled by the user.');
        yield StateErrorSignUp(SignUpError.UserCancelled);
        yield StateInitial();
        break;
      case FacebookLoginStatus.error:
        print('Something went wrong with the login process.\n'
            'Here\'s the error Facebook gave us: ${result.errorMessage}');
        yield StateErrorSignUp(SignUpError.Unknown);
        yield StateInitial();
        break;
    }
  }
}
