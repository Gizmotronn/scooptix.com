part of 'ticket_bloc.dart';

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

class StateNoPaymentRequired extends AcceptInvitationState {
  final List<TicketRelease> releases;
  final String last4;

  StateNoPaymentRequired(this.releases, this.last4);
}

class StatePaymentRequired extends AcceptInvitationState {
  final List<TicketRelease> releases;

  StatePaymentRequired(this.releases);}

class StateNoTicketsLeft extends AcceptInvitationState {}

class StatePastCutoffTime extends AcceptInvitationState {}

class StateInvitationAccepted extends AcceptInvitationState {
  final Ticket ticket;

  const StateInvitationAccepted(this.ticket);
}

class StateTicketAlreadyIssued extends AcceptInvitationState {
  final Ticket ticket;

  const StateTicketAlreadyIssued(this.ticket);
}
