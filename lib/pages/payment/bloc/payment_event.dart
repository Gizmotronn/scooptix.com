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
  final bool saveCreditCard;
  const EventConfirmSetupIntent(this.paymentMethod, this.saveCreditCard);
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
  final Discount discount;

  const EventRequestPI(this.selectedRelease, this.quantity, this.discount);
}

class EventTicketSelected extends PaymentEvent {
  final TicketRelease selectedRelease;
  final List<ReleaseManager> managers;

  const EventTicketSelected(this.managers, this.selectedRelease);
}

class EventLoadAvailableReleases extends PaymentEvent {
  final Event event;

  const EventLoadAvailableReleases(this.event);
}

class EventApplyDiscount extends PaymentEvent {
  final String code;
  final TicketRelease selectedRelease;

  const EventApplyDiscount(this.code, this.selectedRelease);
}
