part of 'payment_bloc.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object> get props => [];
}

class EventCancelPayment extends PaymentEvent {}

class EventChangePaymentMethod extends PaymentEvent {}

class EventConfirmSetupIntent extends PaymentEvent {
  final PaymentMethod paymentMethod;
  final String setupIntentId;
  const EventConfirmSetupIntent(this.paymentMethod, this.setupIntentId);
}

class EventConfirmPayment extends PaymentEvent {
  final String clientSecret;
  final String paymentMethodId;
  const EventConfirmPayment(this.clientSecret, this.paymentMethodId);
}

class EventRequestPI extends PaymentEvent {}

class EventStartPaymentProcess extends PaymentEvent {
  final TicketRelease release;
  final int quantity;

  const EventStartPaymentProcess(this.release, this.quantity);
}

class EventLoadAvailableReleases extends PaymentEvent {
  final Event event;

  const EventLoadAvailableReleases(this.event);
}