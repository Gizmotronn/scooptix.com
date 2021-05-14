part of 'my_tickets_bloc.dart';

abstract class MyTicketsState extends Equatable {
  const MyTicketsState();

  @override
  List<Object> get props => [];
}

class StateLoading extends MyTicketsState {}

class StateTicketOverview extends MyTicketsState {
  final List<Ticket> tickets;

  const StateTicketOverview(this.tickets);
}
