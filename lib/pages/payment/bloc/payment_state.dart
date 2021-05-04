part of 'payment_bloc.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();
  @override
  List<Object> get props => [];
}

class StateInitial extends PaymentState {}

class StateLoading extends PaymentState {}

class StateLoadingPaymentMethod extends StatePaymentOptionAvailable {}

class StateLoadingPaymentIntent extends PaymentState {}

class StateCardUpdated extends PaymentState {}

class StatePaymentOptionAvailable extends PaymentState {
  const StatePaymentOptionAvailable();
}

class StateFreeTicketSelected extends StatePaymentOptionAvailable {
  const StateFreeTicketSelected() : super();
}

class StateFreeTicketAlreadyOwned extends PaymentState {
  const StateFreeTicketAlreadyOwned() : super();
}

class StatePaidTickets extends StatePaymentOptionAvailable {
  const StatePaidTickets() : super();
}

class StatePaymentCompleted extends PaymentState {
  final String message;
  const StatePaymentCompleted(this.message);
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
