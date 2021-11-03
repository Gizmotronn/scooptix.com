import 'package:ticketapp/model/birthday_lists/attendee.dart';
import 'package:ticketapp/model/bookings/booking_data.dart';

class Booking {
  String docId;
  BookingData data;
  int maxGuests;
  List<AttendeeTicket> attendees = [];
  String uuid;

  Booking({
    required this.docId,
    required this.data,
    required this.maxGuests,
    required this.attendees,
    required this.uuid,
  });
}
