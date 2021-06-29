import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ticketapp/model/birthday_lists/attendee.dart';
import 'package:ticketapp/model/birthday_lists/birthdaylist.dart';
import 'package:ticketapp/model/event.dart';
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
      yield* _createList(event.event, event.numGuests);
    }
  }

  Stream<BirthdayListState> _loadExistingList(Event event) async* {
    yield StateLoading();
    BirthdayList bDayList = await BirthdayListRepository.instance.loadExistingList(event.docID);
    if (bDayList == null) {
      if (UserRepository.instance.currentUser().dob.difference(event.date).inDays.abs() % 365.25 > 14 &&
          UserRepository.instance.currentUser().dob.difference(event.date).inDays.abs() % 365.25 - 365.25 < -14) {
        yield StateTooFarAway();
      } else {
        yield StateNoList();
      }
    } else {
      bDayList.attendees = await TicketRepository.instance
          .loadBookingAttendees(event, UserRepository.instance.currentUser().firebaseUserID);
      yield StateExistingList(bDayList);
    }
  }

  Stream<BirthdayListState> _createList(Event event, int numGuests) async* {
    yield StateCreatingList();
    String uuid = await BirthdayListRepository.instance
        .createOrLoadUUIDMap(event, UserRepository.instance.currentUser().firebaseUserID, "", numGuests);
    // Issue ticket for list creator
    // TODO: select correct ticket release
    TicketRepository.instance.issueTickets(event, event.getManagersWithActiveReleases()[0].getActiveRelease(), 1, null);
    yield StateExistingList(BirthdayList()
      ..uuid = uuid
      ..estGuests = numGuests
      ..attendees = [
        AttendeeTicket()
          ..dateAccepted = DateTime.now()
          ..name =
              "${UserRepository.instance.currentUser().firstname} ${UserRepository.instance.currentUser().lastname}"
      ]);
  }
}
