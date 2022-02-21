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
        emit(StateAutoLoggedIn(fbUser.email, UserRepository.instance.currentUser()!.firstname,
            UserRepository.instance.currentUser()!.lastname));
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
