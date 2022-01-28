import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ticketapp/model/ticket.dart';
import 'package:ticketapp/repositories/ticket_repository.dart';
import 'package:ticketapp/repositories/user_repository.dart';

part 'my_tickets_event.dart';
part 'my_tickets_state.dart';

class MyTicketsBloc extends Bloc<MyTicketsEvent, MyTicketsState> {
  MyTicketsBloc() : super(StateLoading()) {
    on<EventLoadMyTickets>(loadMyTickets);
  }

  loadMyTickets(event, emit) async {
    emit(StateLoading());
    List<Ticket> tickets =
        await TicketRepository.instance.loadMyTickets(UserRepository.instance.currentUser()!.firebaseUserID);
    emit(StateTicketOverview(tickets));
  }
}
