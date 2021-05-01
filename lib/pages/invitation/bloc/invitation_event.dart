part of 'invitation_bloc.dart';

abstract class InvitationEvent extends Equatable {
  const InvitationEvent();

  @override
  List<Object> get props => [];
}

class EventPaymentSuccessful extends InvitationEvent {
  final LinkType linkType;
  final TicketRelease release;
  final int quantity;
  final Discount discount;

  const EventPaymentSuccessful(this.linkType, this.release, this.quantity, this.discount);
}

class EventCheckInvitationStatus extends InvitationEvent {
  final String uid;
  final Event event;
  // Will directly take the user to the payment page
  final bool forwardToPayment;

  const EventCheckInvitationStatus(this.uid, this.event, this.forwardToPayment);
}

class EventAcceptInvitation extends InvitationEvent {
  final LinkType linkType;
  final TicketRelease release;

  const EventAcceptInvitation(this.linkType, this.release);
}

class EventGoToPayment extends InvitationEvent {
  final List<TicketRelease> releases;

  const EventGoToPayment(this.releases);
}
