part of 'accept_invitation_bloc.dart';

abstract class AcceptInvitationState extends Equatable {
  const AcceptInvitationState();

  @override
  List<Object> get props => [];
}

class StateLoading extends AcceptInvitationState {
  final String message;

  const StateLoading({this.message = "Loading ..."});
}

class StateError extends AcceptInvitationState {}

class StateInvitationPending extends AcceptInvitationState {}

class StateNoTicketsLeft extends AcceptInvitationState {}

class StatePastCutoffTime extends AcceptInvitationState {}

class StateInvitationAccepted extends AcceptInvitationState {}

class StateTicketAlreadyIssued extends AcceptInvitationState {
  final Ticket ticket;

  const StateTicketAlreadyIssued(this.ticket);
}
