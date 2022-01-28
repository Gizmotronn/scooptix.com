import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:ticketapp/model/user.dart';
import 'package:ticketapp/repositories/payment_repository.dart';
import 'package:ticketapp/repositories/presale_repository.dart';
import 'package:ticketapp/repositories/user_repository.dart';
import 'package:ticketapp/services/firebase.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc() : super(StateInitial()) {
    on<EventEmailProvided>(_checkUserStatus);
    on<EventLoginPressed>(_loginExistingUser);
    on<EventCreateNewUser>(_createUser);
    on<EventChangeEmail>((event, emit) => emit(StateInitial()));
    on<EventPageLoad>((event, emit) => _signInCurrentUser(emit));
    on<EventLogout>((event, emit) => _logout(emit));
    on<EventEmailsConfirmed>((event, emit) => emit(StateNewUserEmailsConfirmed()));
    on<EventPasswordsConfirmed>((event, emit) => emit(StatePasswordsConfirmed(null)));
    on<EventSSOEmailsConfirmed>((event, emit) => emit(StatePasswordsConfirmed(event.uid)));
  }

  /// Checks whether the entered email address is new or from an existing user
  _checkUserStatus(EventEmailProvided event, emit) async {
    print("checking user status");
    emit(StateLoadingUserData());
    bool? isInUse = await FBServices.instance.isEmailInUse(event.email);
    if (isInUse == null) {
      emit(StateInvalidEmail());
    } else if (isInUse) {
      emit(StateExistingUserEmail());
    } else {
      emit(StateNewUserEmail());
    }
  }

  _loginExistingUser(EventLoginPressed event, emit) async {
    emit(StateLoadingLogin());
    auth.User? fbUser = await FBServices.instance.logIn(event.email, event.pw);
    if (fbUser == null) {
      emit(StateLoginFailed());
    } else {
      await UserRepository.instance.getUser(fbUser.uid);

      emit(StateLoggedIn(event.email, UserRepository.instance.currentUser()!.firstname!,
          UserRepository.instance.currentUser()!.lastname!));
    }
  }

  /// Creates a new user, used by email / password as well as SSO signups.
  /// For email / password uid should be null
  /// For SSO password should be empty and uid should be the uid returned by the SSO
  _createUser(EventCreateNewUser event, emit) async {
    if (event.uid == null && event.pw.length < 8) {
      // Notify UI about error and revert to previous state
      emit(StateErrorSignUp(SignUpError.Password));
      emit(StateNewUserEmail());
    } else {
      emit(StateLoadingCreateUser());
      await UserRepository.instance
          .createUser(event.email, event.pw, event.firstName, event.lastName, event.dob, event.gender, uid: event.uid);
      if (UserRepository.instance.currentUserNotifier.value == null) {
        // Notify UI about error and revert to previous state
        emit(StateErrorSignUp(SignUpError.Unknown));
        emit(StatePasswordsConfirmed(event.uid));
      } else {
        emit(StateLoggedIn(UserRepository.instance.currentUser()!.email!,
            UserRepository.instance.currentUser()!.firstname!, UserRepository.instance.currentUser()!.lastname!));
      }
    }
  }

  /* Stream<AuthenticationState> _signInWithGoogle({bool retry = true}) async* {
    yield StateLoadingSSO();
    GoogleSignIn _googleSignIn = GoogleSignIn();
    try {
      GoogleSignInAccount? gUser = await _googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth = await gUser!.authentication;
      final auth.AuthCredential credential = auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      auth.UserCredential authResult = await auth.FirebaseAuth.instance.signInWithCredential(credential);
      auth.User? fbUser = authResult.user;
      // If authentication was successful
      if (fbUser != null) {
        await UserRepository.instance.getUser(fbUser.uid);
        if (UserRepository.instance.currentUserNotifier.value == null) {
          String firstName = fbUser.displayName != null ? fbUser.displayName!.split(" ")[0] : "";
          String lastName = fbUser.displayName != null && fbUser.displayName!.split(" ").length > 1
              ? fbUser.displayName!.split(" ")[1]
              : "";
          yield StateNewSSOUser(gUser.email, fbUser.uid, firstName, lastName);
        } else {
          yield StateLoggedIn(gUser.email, UserRepository.instance.currentUser()!.firstname!,
              UserRepository.instance.currentUser()!.lastname!);
        }
      } else {
        BugsnagNotifier.instance.notify("Error signing in with Google.", StackTrace.empty);
        yield StateErrorSignUp(SignUpError.Unknown);
        yield StateInitial();
      }
    } catch (e) {
      if (retry) {
        yield* _signInWithGoogle(retry: false);
      } else {
        yield StateErrorSignUp(SignUpError.UserCancelled);
        yield StateInitial();
      }
    }
  }

  Stream<AuthenticationState> _signInWithApple() async* {
    yield StateLoadingSSO();
    try {
      auth.User? fbUser = await FirebaseAuthOAuth().openSignInFlow("apple.com", ["email"]);
      if (fbUser != null) {
        User? user = await UserRepository.instance.getUser(fbUser.uid);
        // New user
        if (user == null) {
          String firstName = fbUser.displayName != null ? fbUser.displayName!.split(" ")[0] : "";
          String lastName = fbUser.displayName != null && fbUser.displayName!.split(" ").length > 1
              ? fbUser.displayName!.split(" ")[1]
              : "";
          yield StateNewSSOUser(fbUser.email!, fbUser.uid, firstName, lastName);
        } else {
          // Existing User
          yield StateLoggedIn(fbUser.email!, user.firstname!, user.lastname!);
        }
      } else {
        BugsnagNotifier.instance.notify("Error signing in with Apple.", StackTrace.empty);
        yield StateErrorSignUp(SignUpError.Unknown);
        yield StateInitial();
      }
    } catch (e, s) {
      print(e);
      BugsnagNotifier.instance.notify(e, s, severity: ErrorSeverity.info);

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
        auth.User? fbUser = await FBServices.instance.signInWithFacebook(result.accessToken.token);
        if (fbUser != null) {
          User? user = await UserRepository.instance.getUser(fbUser.uid);
          // New user
          if (user == null) {
            String firstName = fbUser.displayName != null ? fbUser.displayName!.split(" ")[0] : "";
            String lastName = fbUser.displayName != null && fbUser.displayName!.split(" ").length > 1
                ? fbUser.displayName!.split(" ")[1]
                : "";
            yield StateNewSSOUser(fbUser.email!, fbUser.uid, firstName, lastName);
          } else {
            // Existing User

            yield StateLoggedIn(fbUser.email!, user.firstname!, user.lastname!);
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
        BugsnagNotifier.instance
            .notify("Error signing in with Facebook. Facebook error: ${result.errorMessage}", StackTrace.empty);
        yield StateErrorSignUp(SignUpError.Unknown);
        yield StateInitial();
        break;
    }
  }*/

  /// Tries to login a previously logged in user.
  _signInCurrentUser(emit) async {
    if (UserRepository.instance.currentUser() == null) {
      auth.User? fbUser = auth.FirebaseAuth.instance.currentUser;
      if (fbUser == null) {
        print("no current user");
        fbUser = await auth.FirebaseAuth.instance.authStateChanges().first;
      }
      if (fbUser == null) {
        print("no state change user");
        emit(StateInitial());
      } else {
        /*await UserRepository.instance.getUser(fbUser.uid);

        // Using SSO it's possible the user has an auth account but no user document
        if (UserRepository.instance.currentUserNotifier.value == null) {
          String firstName = fbUser.displayName != null ? fbUser.displayName!.split(" ")[0] : "";
          String lastName = fbUser.displayName != null && fbUser.displayName!.split(" ").length > 1
              ? fbUser.displayName!.split(" ")[1]
              : "";
          yield StateNewSSOUser(fbUser.email!, fbUser.uid, firstName, lastName);
        } else {*/
        emit(StateAutoLoggedIn(fbUser.email, UserRepository.instance.currentUser()!.firstname,
            UserRepository.instance.currentUser()!.lastname));
        // }
      }
    } else {
      emit(StateLoggedIn(UserRepository.instance.currentUser()!.email!,
          UserRepository.instance.currentUser()!.firstname!, UserRepository.instance.currentUser()!.lastname!));
    }
  }

  _logout(emit) async* {
    await auth.FirebaseAuth.instance.signOut();
    UserRepository.instance.dispose();
    PaymentRepository.instance.dispose();
    PreSaleRepository.instance.dispose();
    emit(StateInitial());
  }
}
