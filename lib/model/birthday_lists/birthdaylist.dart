import 'package:ticketapp/model/birthday_lists/attendee.dart';

class BirthdayList {
  String uuid;
  int estGuests;
  List<AttendeeTicket> attendees;

  static String toDBString() {
    return "birthday_list";
  }
}
