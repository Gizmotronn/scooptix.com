part of 'authentication_bloc.dart';

enum SignUpError { Password, UserCancelled, Unknown }

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object> get props => [];
}

class StateInitial extends AuthenticationState {}

class StateInvalidEmail extends StateInitial {}

class StateLoadingUserData extends StateInitial {}

class StateLoadingLogin extends StateExistingUserEmail {}

class StateLoadingSSO extends StateExistingUserEmail {}

class StateLoadingCreateUser extends StateExistingUserEmail {}

class StateNewSSOUser extends AuthenticationState {
  final String email;
  final String firstName;
  final String lastName;
  final String uid;

  StateNewSSOUser(this.email, this.uid, this.firstName, this.lastName);
}

class StateExistingUserEmail extends AuthenticationState {}

class StateNewUserEmail extends AuthenticationState {}

class StateNewUserEmailsConfirmed extends AuthenticationState {}

class StatePasswordsConfirmed extends AuthenticationState {
  // Used for SSO, should be null for other authentication
  final String uid;

  const StatePasswordsConfirmed(this.uid);
}

class StateLoginFailed extends StateExistingUserEmail {}

class StateLoggedIn extends AuthenticationState {
  final String email;
  final String firstName;
  final String lastName;

  StateLoggedIn(this.email, this.firstName, this.lastName);
}

class StateErrorSignUp extends AuthenticationState {
  final SignUpError error;

  const StateErrorSignUp(this.error);
}
