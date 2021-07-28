import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ticketapp/model/bookings/booking_data.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/repositories/birthdaylist_repository.dart';

part 'bookings_event.dart';
part 'bookings_state.dart';

class BookingsBloc extends Bloc<BookingsEvent, BookingsState> {
  BookingsBloc() : super(StateLoading());

  @override
  Stream<BookingsState> mapEventToState(
    BookingsEvent event,
  ) async* {
    if (event is EventLoadBookingData) {
      yield* _loadBookingData(event.event);
    }
  }

  Stream<BookingsState> _loadBookingData(Event event) async* {
    yield StateLoading();
    BookingData? booking = await BirthdayListRepository.instance.loadBookingData(event);
    print(booking);
    if (booking != null) {
      yield StateBookingData(booking);
    } else {
      yield StateNoBookingsAvailable();
    }
  }
}
