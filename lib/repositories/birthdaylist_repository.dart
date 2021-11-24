import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ticketapp/model/birthday_lists/birthdaylist.dart';
import 'package:ticketapp/model/bookings/booking.dart';
import 'package:ticketapp/model/bookings/booking_data.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/repositories/ticket_repository.dart';
import 'package:ticketapp/repositories/user_repository.dart';
import 'package:ticketapp/services/bugsnag_wrapper.dart';
import 'package:http/http.dart' as http;

enum BirthdayListStatus { Pending, Declined, Accepted }

extension BirthdayListStatusExtension on BirthdayListStatus {
  String getDBString() {
    return this.toString().split(".")[1].toLowerCase();
  }

  String getDisplayString() {
    return this.toString().split(".")[1];
  }
}

enum PassType { PriorityPass, QPass, CheckIn, Invitation, Barchella, Birthdaylist }

extension PassTypeExtension on PassType {
  String toDisplayString() {
    return this.toString().split(".")[1];
  }

  String toDBString() {
    return this.toString().split(".")[1].toLowerCase();
  }
}

class BirthdayListRepository {
  static BirthdayListRepository? _instance;

  static BirthdayListRepository get instance {
    if (_instance == null) {
      _instance = BirthdayListRepository._();
    }
    return _instance!;
  }

  BirthdayListRepository._();

  dispose() {
    _instance = null;
  }

  Future<BookingData?> loadBookingDataForEvent(Event event) async {
    QuerySnapshot bookingsSnapshot =
        await FirebaseFirestore.instance.collection("ticketevents").doc(event.docID).collection("bookings").get();
    if (bookingsSnapshot.size > 0) {
      return BookingData()
        ..docId = bookingsSnapshot.docs[0].id
        ..benefits = bookingsSnapshot.docs[0].get("benefits").cast<String>().toList();
    } else {
      return null;
    }
  }

  Future<List<Booking>> loadBookingData() async {
    QuerySnapshot bookingsSnapshot = await FirebaseFirestore.instance
        .collection("uuidmap")
        .where("uid", isEqualTo: UserRepository.instance.currentUser()!.firebaseUserID)
        .where("eventdate", isGreaterThan: DateTime.now().subtract(Duration(hours: 12)))
        .get();
    List<Booking> bookings = [];

    await Future.wait(bookingsSnapshot.docs.map((element) async {
      DocumentSnapshot bSnapshot = await FirebaseFirestore.instance
          .collection("ticketevents")
          .doc(element.get("event"))
          .collection("bookings")
          .doc(element.get("booking_type"))
          .get();
      bookings.add(Booking(
          docId: element.id,
          attendees: await TicketRepository.instance
              .loadBookingAttendees(element.get("event"), UserRepository.instance.currentUser()!.firebaseUserID),
          maxGuests: element.get("num_guests"),
          uuid: element.get("uuid"),
          data: BookingData()
            ..docId = bSnapshot.id
            ..benefits = bSnapshot.get("benefits").cast<String>().toList()));
    }));

    return bookings;
  }

  Future<String?> makeBooking(Event event, BookingData booking, int numGuests) async {
    http.Response? response;
    try {
      response = await http.post(Uri.parse("https://appollo-devops.web.app/processBooking"), body: {
        "uid": UserRepository.instance.currentUser()!.firebaseUserID,
        "eventid": event.docID,
        "event_date": event.date.toString(),
        "booking": booking.docId,
        "guests": numGuests.toString()
      });
      print(response.statusCode);
      print(response.body);
    } on SocketException catch (ex) {
      print(ex);
      BugsnagNotifier.instance.notify("Error making booking\n $ex", StackTrace.empty, severity: ErrorSeverity.error);
    }
    if (response != null && response.statusCode == 200) {
      return json.decode(response.body)["uuid"];
    } else {
      BugsnagNotifier.instance
          .notify("Error making booking\n $response", StackTrace.empty, severity: ErrorSeverity.error);
      return null;
    }
  }

  Future<BirthdayList?> loadExistingList(String eventId) async {
    QuerySnapshot listSnapshot = await FirebaseFirestore.instance
        .collection("uuidmap")
        .where("event", isEqualTo: eventId)
        .where("promoter", isEqualTo: UserRepository.instance.currentUser()!.firebaseUserID)
        .where("type", isEqualTo: "birthdaylist")
        .get();

    if (listSnapshot.size == 0) {
      return null;
    } else {
      return BirthdayList()..uuid = listSnapshot.docs[0].get("uuid");
    }
  }
}
