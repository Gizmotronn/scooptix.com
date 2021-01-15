part of 'payment_bloc.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();
  @override
  List<Object> get props => [];
}

class StateInitial extends PaymentState {
}

class StateLoading extends PaymentState {
}

class StateFinalizePayment extends PaymentState {
  final String last4;
  final int price;
  final String clientSecret;
  final String paymentMethodId;
  const StateFinalizePayment(this.last4, this.price, this.clientSecret, this.paymentMethodId);
}

class PaymentCompletedState extends PaymentState {
  final String message;
  const PaymentCompletedState(this.message);
}

class StatePaymentError extends PaymentState {
  final String message;
  const StatePaymentError(this.message);
}

class SetupIntentConfirmedState extends PaymentState {
  final String last4;
  const SetupIntentConfirmedState(
      this.last4,
      );
}

class StateSIRequiresPaymentMethod extends PaymentState {
  final String setupIntentId;
  const StateSIRequiresPaymentMethod(this.setupIntentId);
}