part of 'payment_bloc.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();
  @override
  List<Object> get props => [];
}

class StateInitial extends PaymentState {}

class StateLoading extends PaymentState {}

class StateLoadingPaymentMethod extends PaymentState {}

class StateLoadingPaymentIntent extends PaymentState {}

class StateNoTicketsAvailable extends PaymentState {}

class StateAddPaymentMethod extends PaymentState {}

class StateUpdating extends PaymentState {}

class StatePaymentOptionAvailable extends PaymentState {
  final List<TicketRelease> releases;
  final TicketRelease selectedRelease;

  const StatePaymentOptionAvailable(this.releases, this.selectedRelease);
}

class StateFreeTicketSelected extends StatePaymentOptionAvailable {
  const StateFreeTicketSelected(releases, selectedRelease) : super(releases, selectedRelease);
}

class StateFreeTicketQuantitySelected extends StatePaymentOptionAvailable {
  const StateFreeTicketQuantitySelected(releases, selectedRelease) : super(releases, selectedRelease);
}

class StatePaidTicketSelected extends StatePaymentOptionAvailable {
  const StatePaidTicketSelected(releases, selectedRelease) : super(releases, selectedRelease);
}

class StatePaidTicketQuantitySelected extends StatePaymentOptionAvailable {
  const StatePaidTicketQuantitySelected(releases, selectedRelease) : super(releases, selectedRelease);
}

class StateFinalizePayment extends PaymentState {
  final String last4;
  final int price;
  final String clientSecret;
  final String paymentMethodId;
  final int quantity;
  const StateFinalizePayment(this.last4, this.price, this.clientSecret, this.paymentMethodId, this.quantity);
}

class StatePaymentCompleted extends PaymentState {
  final TicketRelease release;
  final int quantity;
  final String message;
  const StatePaymentCompleted(this.message, this.release, this.quantity);
}

class StateFreeTicketIssued extends PaymentState {
final TicketRelease release;
final String message;

const StateFreeTicketIssued(this.message, this.release);
}

class StatePaymentError extends PaymentState {
  final String message;
  const StatePaymentError(this.message);
}

class StateSIRequiresPaymentMethod extends PaymentState {
  final String setupIntentId;
  const StateSIRequiresPaymentMethod(this.setupIntentId);
}
