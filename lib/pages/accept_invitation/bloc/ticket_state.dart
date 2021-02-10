part of 'ticket_bloc.dart';

abstract class TicketState extends Equatable {
  const TicketState();

  @override
  List<Object> get props => [];
}

class StateLoading extends TicketState {
  final String message;

  const StateLoading({this.message = "Loading ..."});
}

class StateError extends TicketState {}

class StatePreviouslyBoughtTickets extends TicketState {
  final List<Ticket> tickets;

  const StatePreviouslyBoughtTickets(this.tickets);
}

class StateNoPaymentRequired extends StatePreviouslyBoughtTickets {
  final List<TicketRelease> releases;
  final TicketRelease selectedRelease;

  StateNoPaymentRequired(this.releases, this.selectedRelease, tickets) : super(tickets);
}

class StatePaymentRequired extends StatePreviouslyBoughtTickets {
  final List<TicketRelease> releases;

  StatePaymentRequired(this.releases, tickets) : super(tickets);
}

class StateWaitForPayment extends TicketState {
  final List<TicketRelease> releases;

  StateWaitForPayment(this.releases);
}

class StateNoTicketsLeft extends TicketState {}

class StatePastCutoffTime extends TicketState {}

class StateInvitationAccepted extends TicketState {
  final List<Ticket> tickets;

  const StateInvitationAccepted(this.tickets);
}

class StateTicketAlreadyIssued extends TicketState {
  final Ticket ticket;

  const StateTicketAlreadyIssued(this.ticket);
}
