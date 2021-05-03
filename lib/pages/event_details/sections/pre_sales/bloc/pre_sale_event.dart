part of 'pre_sale_bloc.dart';

abstract class PreSaleEvent extends Equatable {
  const PreSaleEvent();

  @override
  List<Object> get props => [];
}

class EventCheckStatus extends PreSaleEvent {
  final Event event;

  const EventCheckStatus(this.event);
}

class EventRegister extends PreSaleEvent {
  final Event event;

  const EventRegister(this.event);
}
