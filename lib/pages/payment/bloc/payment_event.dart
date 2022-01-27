part of 'payment_bloc.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object> get props => [];
}

class EventConfirmSetupIntent extends PaymentEvent {
  final PaymentMethod paymentMethod;
  final bool saveCreditCard;
  final Event event;
  const EventConfirmSetupIntent(this.paymentMethod, this.saveCreditCard, this.event);
}

class EventConfirmPayment extends PaymentEvent {
  final String clientSecret;
  final String paymentMethodId;
  const EventConfirmPayment(this.clientSecret, this.paymentMethodId);
}

class EventRequestPI extends PaymentEvent {
  final Map<TicketRelease, int> selectedRelease;
  final Discount? discount;
  final Event event;
  final BuildContext context;

  const EventRequestPI(this.selectedRelease, this.discount, this.event, this.context);
}

class EventRequestFreeTickets extends PaymentEvent {
  final Map<TicketRelease, int> selectedRelease;
  final Event event;

  const EventRequestFreeTickets(this.selectedRelease, this.event);
}

class EventLoadAvailableReleases extends PaymentEvent {
  final Map<TicketRelease, int> selectedTickets;
  final Event event;

  const EventLoadAvailableReleases(this.selectedTickets, this.event);
}
