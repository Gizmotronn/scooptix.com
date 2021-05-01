part of 'ticket_bloc.dart';

abstract class TicketState extends Equatable {
  const TicketState();

  @override
  List<Object> get props => [];
}

class StateLoading extends TicketState {
  final String message;

  const StateLoading({this.message = "Loading ..."});
}

class StateError extends TicketState {}

class StateDiscountApplied extends TicketState {
  final Discount discount;

  StateDiscountApplied(this.discount);
}

class StateDiscountCodeLoading extends TicketState {}

class StateDiscountCodeInvalid extends TicketState {}
