part of 'payment_bloc.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object> get props => [];
}

class EventCancelPayment extends PaymentEvent {}

class EventConfirmSetupIntent extends PaymentEvent {
  final PaymentMethod paymentMethod;
  final bool saveCreditCard;
  const EventConfirmSetupIntent(this.paymentMethod, this.saveCreditCard);
}

class EventConfirmPayment extends PaymentEvent {
  final String clientSecret;
  final String paymentMethodId;
  const EventConfirmPayment(this.clientSecret, this.paymentMethodId);
}

class EventRequestPI extends PaymentEvent {
  final Map<TicketRelease, int> selectedRelease;
  final Discount discount;
  final LinkType linkType;

  const EventRequestPI(this.selectedRelease, this.discount, this.linkType);
}

class EventRequestFreeTickets extends PaymentEvent {
  final Map<TicketRelease, int> selectedRelease;
  final LinkType linkType;

  const EventRequestFreeTickets(this.selectedRelease, this.linkType);
}

class EventLoadAvailableReleases extends PaymentEvent {
  final Map<TicketRelease, int> selectedTickets;

  const EventLoadAvailableReleases(this.selectedTickets);
}
