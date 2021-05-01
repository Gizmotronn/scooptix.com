part of 'invitation_bloc.dart';

abstract class InvitationState extends Equatable {
  const InvitationState();

  @override
  List<Object> get props => [];
}

class StateLoading extends InvitationState {
  final String message;

  const StateLoading({this.message = "Loading ..."});
}

class StateError extends InvitationState {}

class StatePreviouslyBoughtTickets extends InvitationState {
  final List<Ticket> tickets;

  const StatePreviouslyBoughtTickets(this.tickets);
}

class StatePaymentRequired extends StatePreviouslyBoughtTickets {
  final List<TicketRelease> releases;

  StatePaymentRequired(this.releases, tickets) : super(tickets);
}

class StateWaitForPayment extends InvitationState {
  final List<TicketRelease> releases;

  StateWaitForPayment(this.releases);
}

class StateNoTicketsLeft extends InvitationState {}

class StatePastCutoffTime extends InvitationState {}

class StateInvitationAccepted extends InvitationState {
  final List<Ticket> tickets;

  const StateInvitationAccepted(this.tickets);
}

class StateTicketAlreadyIssued extends InvitationState {
  final Ticket ticket;

  const StateTicketAlreadyIssued(this.ticket);
}
