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

class StateNoPaymentRequired extends PaymentState {
  final List<TicketRelease> releases;

  const StateNoPaymentRequired(this.releases);
}

class StatePaymentRequired extends PaymentState {
  final List<TicketRelease> releases;

  const StatePaymentRequired(this.releases);
}

class StateFinalizePayment extends PaymentState {
  final String last4;
  final int price;
  final String clientSecret;
  final String paymentMethodId;
  final int quantity;
  const StateFinalizePayment(this.last4, this.price, this.clientSecret, this.paymentMethodId, this.quantity);
}

class PaymentCompletedState extends PaymentState {
  final String message;
  const PaymentCompletedState(this.message);
}

class StatePaymentError extends PaymentState {
  final String message;
  const StatePaymentError(this.message);
}

class StateSIRequiresPaymentMethod extends PaymentState {
  final String setupIntentId;
  const StateSIRequiresPaymentMethod(this.setupIntentId);
}
