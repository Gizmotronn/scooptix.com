part of 'ticket_bloc.dart';

abstract class TicketEvent extends Equatable {
  const TicketEvent();

  @override
  List<Object> get props => [];
}

class EventApplyDiscount extends TicketEvent {
  final Event event;
  final String code;
  final int quantity;

  const EventApplyDiscount(this.event, this.code, this.quantity);
}

class EventRemoveDiscount extends TicketEvent {}
