part of 'ticket_bloc.dart';

abstract class TicketEvent extends Equatable {
  const TicketEvent();

  @override
  List<Object> get props => [];
}

class EventPaymentSuccessful extends TicketEvent {
  final LinkType linkType;
  final TicketRelease release;
  final int quantity;

  const EventPaymentSuccessful(this.linkType, this.release, this.quantity);
}

class EventCheckInvitationStatus extends TicketEvent {
  final String uid;
  final Event event;

  const EventCheckInvitationStatus(this.uid, this.event);
}

class EventAcceptInvitation extends TicketEvent {
  final LinkType linkType;
  final TicketRelease release;

  const EventAcceptInvitation(this.linkType, this.release);
}

class EventGoToPayment extends TicketEvent {
  final List<TicketRelease> releases;

  const EventGoToPayment(this.releases);
}
