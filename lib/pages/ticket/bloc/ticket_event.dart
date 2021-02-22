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
  final Discount discount;

  const EventPaymentSuccessful(this.linkType, this.release, this.quantity, this.discount);
}

class EventCheckInvitationStatus extends TicketEvent {
  final String uid;
  final Event event;
  // Will directly take the user to the payment page
  final bool forwardToPayment;

  const EventCheckInvitationStatus(this.uid, this.event, this.forwardToPayment);
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
