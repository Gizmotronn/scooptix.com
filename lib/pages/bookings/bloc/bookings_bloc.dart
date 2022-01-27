import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ticketapp/model/bookings/booking.dart';
import 'package:ticketapp/repositories/birthdaylist_repository.dart';

part 'bookings_event.dart';
part 'bookings_state.dart';

class BookingsBloc extends Bloc<BookingsEvent, BookingsState> {
  BookingsBloc() : super(StateLoading()){
   on<EventLoadBookings>(_loadBookings);
  }

  _loadBookings(event, emit) async {
    emit(StateLoading());
    List<Booking> bookings = await BirthdayListRepository.instance.loadBookingData();
    if (bookings.isEmpty) {
      emit(StateNoBookings());
    } else {
      emit(StateBookings(bookings));
    }
  }
}
