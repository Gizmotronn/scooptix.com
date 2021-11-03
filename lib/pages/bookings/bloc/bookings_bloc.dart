import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ticketapp/model/bookings/booking.dart';
import 'package:ticketapp/repositories/birthdaylist_repository.dart';

part 'bookings_event.dart';
part 'bookings_state.dart';

class BookingsBloc extends Bloc<BookingsEvent, BookingsState> {
  BookingsBloc() : super(StateLoading());

  @override
  Stream<BookingsState> mapEventToState(
    BookingsEvent event,
  ) async* {
    if (event is EventLoadBookings) {
      yield* _loadBookings();
    }
  }

  Stream<BookingsState> _loadBookings() async* {
    yield StateLoading();
    List<Booking> bookings = await BirthdayListRepository.instance.loadBookingData();
    if (bookings.isEmpty) {
      yield StateNoBookings();
    } else {
      yield StateBookings(bookings);
    }
  }
}
