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
  BirthdayListBloc() : super(StateLoading()) {
    on<EventLoadExistingList>(_loadExistingList);
    on<EventCreateList>(_createList);
    on<EventLoadBookingData>(_loadBookingData);
  }

  _loadBookingData(EventLoadBookingData event, emit) async {
    emit(StateLoading());
    BookingData? booking = await BirthdayListRepository.instance.loadBookingDataForEvent(event.event);
    print(booking);
    if (booking != null) {
      emit(StateBookingData(booking));
    } else {
      emit(StateNoBookingsAvailable());
    }
  }

  _loadExistingList(EventLoadExistingList event, emit) async {
    emit(StateLoading());
    BirthdayList? bDayList = await BirthdayListRepository.instance.loadExistingList(event.event.docID!);
    if (bDayList == null) {
      if (UserRepository.instance.currentUser()!.dob!.difference(event.event.date).inDays.abs() % 365.25 > 14 &&
          UserRepository.instance.currentUser()!.dob!.difference(event.event.date).inDays.abs() % 365.25 - 365.25 <
              -14) {
        emit(StateTooFarAway());
      } else {
        emit(StateNoList());
      }
    } else {
      bDayList.attendees = await TicketRepository.instance
          .loadBookingAttendees(event.event.docID!, UserRepository.instance.currentUser()!.firebaseUserID);
      emit(StateExistingList(bDayList));
    }
  }

  _createList(EventCreateList event, emit) async {
    emit(StateCreatingList());
    String? uuid = await BirthdayListRepository.instance.makeBooking(event.event, event.booking, event.numGuests);
    // Issue ticket for list creator
    TicketRelease? bookingTicket = event.event.getReleaseForBooking();
    if (uuid == null || bookingTicket == null) {
      emit(StateError("Bookings are currently not available. Sorry for any inconvenience."));
    } else {
      //TicketRepository.instance.acceptInvitation(event, bookingTicket);
      emit(StateExistingList(BirthdayList()
        ..uuid = uuid
        ..estGuests = event.numGuests
        ..attendees = [
          AttendeeTicket()
            ..dateAccepted = DateTime.now()
            ..name =
                "${UserRepository.instance.currentUser()!.firstname} ${UserRepository.instance.currentUser()!.lastname}"
        ]));
    }
  }
}
