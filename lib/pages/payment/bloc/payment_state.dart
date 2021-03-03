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
  final List<ReleaseManager> managers;
  final Discount discount;

  const StatePaymentOptionAvailable(this.managers, this.discount);
}

class StateFreeTicketSelected extends StatePaymentOptionAvailable {
  const StateFreeTicketSelected(releases, {discount}) : super(releases, discount);
}

class StateFreeTicketQuantitySelected extends StatePaymentOptionAvailable {
  const StateFreeTicketQuantitySelected(releases, {discount}) : super(releases, discount);
}

class StatePaidTicketSelected extends StatePaymentOptionAvailable {
  const StatePaidTicketSelected(releases, {discount}) : super(releases, discount);
}

class StatePaidTicketQuantitySelected extends StatePaymentOptionAvailable {
  const StatePaidTicketQuantitySelected(releases, {discount}) : super(releases, discount);
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

class StateDiscountCodeInvalid extends PaymentState {}

class StateDiscountCodeLoading extends PaymentState {}
