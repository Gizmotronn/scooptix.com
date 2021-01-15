part of 'payment_bloc.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object> get props => [];
}


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

class EventRequestPI extends PaymentEvent {
  final String eventId;
  final String ticketId;
  final int quantity;
  const EventRequestPI(this.eventId, this.ticketId, this.quantity);
}

class EventGetSetupIntent extends PaymentEvent {}