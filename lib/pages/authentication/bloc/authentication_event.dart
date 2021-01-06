part of 'authentication_bloc.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

class EventChangeEmail extends AuthenticationEvent {}

class EventGoogleSignIn extends AuthenticationEvent {}

class EventFacebookSignIn extends AuthenticationEvent {}

class EventAppleSignIn extends AuthenticationEvent {}

class EventEmailProvided extends AuthenticationEvent {
  final String email;
  const EventEmailProvided(this.email);
}

class EventLoginPressed extends AuthenticationEvent {
  final String email;
  final String pw;
  const EventLoginPressed(this.email, this.pw);
}

class EventSignUpPressed extends AuthenticationEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String pw;
  const EventSignUpPressed(this.firstName, this.lastName, this.email, this.pw);
}

class EventCreateNewUser extends AuthenticationEvent {
  final String email;
  final String pw;
  final String firstName;
  final String lastName;
  final DateTime dob;
  final int gender;

  const EventCreateNewUser(this.email, this.pw, this.firstName, this.lastName, this.dob, this.gender);
}
