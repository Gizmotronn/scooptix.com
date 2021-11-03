import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ticketapp/model/birthday_lists/attendee.dart';
import 'package:ticketapp/model/birthday_lists/birthdaylist.dart';
import 'package:ticketapp/model/bookings/booking_data.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/model/ticket_release.dart';
import 'package:ticketapp/repositories/birthdaylist_repository.dart';
import 'package:ticketapp/repositories/ticket_repository.dart';
import 'package:ticketapp/repositories/user_repository.dart';

part 'birthday_list_event.dart';
part 'birthday_list_state.dart';

class BirthdayListBloc extends Bloc<BirthdayListEvent, BirthdayListState> {
  BirthdayListBloc() : super(StateLoading());

  @override
  Stream<BirthdayListState> mapEventToState(
    BirthdayListEvent event,
  ) async* {
    if (event is EventLoadExistingList) {
      yield* _loadExistingList(event.event);
    } else if (event is EventCreateList) {
      yield* _createList(event.event, event.booking, event.numGuests);
    } else if (event is EventLoadBookingData) {
      yield* _loadBookingData(event.event);
    }
  }

  Stream<BirthdayListState> _loadBookingData(Event event) async* {
    yield StateLoading();
    BookingData? booking = await BirthdayListRepository.instance.loadBookingDataForEvent(event);
    print(booking);
    if (booking != null) {
      yield StateBookingData(booking);
    } else {
      yield StateNoBookingsAvailable();
    }
  }

  Stream<BirthdayListState> _loadExistingList(Event event) async* {
    yield StateLoading();
    BirthdayList? bDayList = await BirthdayListRepository.instance.loadExistingList(event.docID!);
    if (bDayList == null) {
      if (UserRepository.instance.currentUser()!.dob!.difference(event.date).inDays.abs() % 365.25 > 14 &&
          UserRepository.instance.currentUser()!.dob!.difference(event.date).inDays.abs() % 365.25 - 365.25 < -14) {
        yield StateTooFarAway();
      } else {
        yield StateNoList();
      }
    } else {
      bDayList.attendees = await TicketRepository.instance
          .loadBookingAttendees(event.docID!, UserRepository.instance.currentUser()!.firebaseUserID);
      yield StateExistingList(bDayList);
    }
  }

  Stream<BirthdayListState> _createList(Event event, BookingData booking, int numGuests) async* {
    yield StateCreatingList();
    String? uuid = await BirthdayListRepository.instance.makeBooking(event, booking, numGuests);
    // Issue ticket for list creator
    TicketRelease? bookingTicket = event.getReleaseForBooking();
    if (uuid == null || bookingTicket == null) {
      yield StateError("Bookings are currently not available. Sorry for any inconvenience.");
    } else {
      //TicketRepository.instance.acceptInvitation(event, bookingTicket);
      yield StateExistingList(BirthdayList()
        ..uuid = uuid
        ..estGuests = numGuests
        ..attendees = [
          AttendeeTicket()
            ..dateAccepted = DateTime.now()
            ..name =
                "${UserRepository.instance.currentUser()!.firstname} ${UserRepository.instance.currentUser()!.lastname}"
        ]);
    }
  }
}
