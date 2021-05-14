part of 'ticket_bloc.dart';

abstract class TicketEvent extends Equatable {
  const TicketEvent();

  @override
  List<Object> get props => [];
}

class EventApplyDiscount extends TicketEvent {
  final Event event;
  final String code;

  const EventApplyDiscount(this.event, this.code);
}

class EventRemoveDiscount extends TicketEvent {}
