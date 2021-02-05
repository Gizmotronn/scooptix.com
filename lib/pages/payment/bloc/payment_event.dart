part of 'payment_bloc.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object> get props => [];
}

class EventCancelPayment extends PaymentEvent {}

class EventChangePaymentMethod extends PaymentEvent {}

class EventAddPaymentMethod extends PaymentEvent {}

class EventConfirmSetupIntent extends PaymentEvent {
  final PaymentMethod paymentMethod;
  const EventConfirmSetupIntent(this.paymentMethod);
}

class EventConfirmSingleUseIntent extends PaymentEvent {
  final PaymentMethod paymentMethod;
  const EventConfirmSingleUseIntent(this.paymentMethod);
}

class EventConfirmPayment extends PaymentEvent {
  final String clientSecret;
  final String paymentMethodId;
  const EventConfirmPayment(this.clientSecret, this.paymentMethodId);
}

class EventRequestPI extends PaymentEvent {
  final TicketRelease selectedRelease;
  final int quantity;

  const EventRequestPI(this.selectedRelease, this.quantity);
}

class EventTicketSelected extends PaymentEvent {
  final TicketRelease selectedRelease;
  final List<TicketRelease> availableReleases;

  const EventTicketSelected(this.availableReleases, this.selectedRelease);
}

class EventLoadAvailableReleases extends PaymentEvent {
  final Event event;

  const EventLoadAvailableReleases(this.event);
}