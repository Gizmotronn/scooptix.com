import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ticketapp/model/birthday_lists/attendee.dart';
import 'package:ticketapp/model/bookings/booking.dart';
import 'package:ticketapp/model/discount.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/model/link_type/advertisementInvite.dart';
import 'package:ticketapp/model/link_type/invitation.dart';
import 'package:ticketapp/model/link_type/memberInvite.dart';
import 'package:ticketapp/model/ticket.dart';
import 'package:ticketapp/model/ticket_release.dart';
import 'package:ticketapp/model/user.dart';
import 'package:ticketapp/repositories/events_repository.dart';
import 'package:ticketapp/repositories/link_repository.dart';
import 'package:ticketapp/repositories/user_repository.dart';
import 'package:http/http.dart' as http;
import 'package:ticketapp/services/bugsnag_wrapper.dart';

class TicketRepository {
  static TicketRepository? _instance;

  static TicketRepository get instance {
    if (_instance == null) {
      _instance = TicketRepository._();
    }
    return _instance!;
  }

  TicketRepository._();

  dispose() {
    _instance = null;
  }

  Future<Discount?> loadDiscount(Event event, String code) async {
    QuerySnapshot<Map<String, dynamic>> discountSnapshot = await FirebaseFirestore.instance
        .collection("ticketevents")
        .doc(event.docID)
        .collection("discounts")
        .where("code", isEqualTo: code)
        .get();
    if (discountSnapshot.size == 0) {
      return null;
    } else {
      try {
        Discount d = Discount.fromMap(discountSnapshot.docs[0].id, discountSnapshot.docs[0].data());
        return d;
      } catch (_) {
        return null;
      }
    }
  }

  Future<List<Ticket>> loadMyTickets(String uid) async {
    List<Ticket> tickets = [];
    QuerySnapshot ticketSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("tickets")
        .where("eventdate", isGreaterThan: DateTime.now().subtract(Duration(days: 14)))
        .get();

    if (ticketSnapshot.size == 0) {
      return [];
    } else {
      List<Future<Event?>> futures = [];
      List<String> loadedEvents = [];
      ticketSnapshot.docs.forEach((ticketDoc) {
        // Make sure we don't load events multiple times
        if (!loadedEvents.contains(ticketDoc.get("eventref"))) {
          futures.add(EventsRepository.instance.loadEventById(ticketDoc.get("eventref")));
          loadedEvents.add(ticketDoc.get("eventref"));
        }
      });

      await Future.wait(futures);

      ticketSnapshot.docs.forEach((ticketDoc) async {
        Ticket ticket;
        try {
          ticket = Ticket.fromMap(
              id: ticketDoc.id,
              event:
                  EventsRepository.instance.events.firstWhere((element) => element.docID == ticketDoc.get("eventref")),
              release: null,
              data: ticketDoc.data() as Map<String, dynamic>);

          if (ticket.event != null) {
            try {
              print("option 1");
              ticket.release = ticket.event!.getRelease(ticketDoc.get("ticket_release_id"));

              tickets.add(ticket);
            } catch (_) {
              // From the old version, tickets won't have a ticket_release_id
              // All our tickets should be single restricted so this should work until there are no more old tickets
              if (ticket.release == null) {
                print("get single release");
                ticket.release = ticket.event!.getReleasesWithSingleTicketRestriction()[0];
              }
              tickets.add(ticket);
            }
          }
        } catch (e, s) {
          BugsnagNotifier.instance.notify("Error loading my tickets \n $e", s, severity: ErrorSeverity.error);
          print(e);
          print(s);
        }
      });
      return tickets;
    }
  }

  Future<List<Ticket>> loadTickets(String uid, Event event, {TicketRelease? release}) async {
    List<Ticket> tickets = [];
    Query<Map<String, dynamic>> q = FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("tickets")
        .where("eventref", isEqualTo: event.docID);

    if (release != null) {
      q = q.where("ticket_release_id", isEqualTo: release.docId);
    }

    QuerySnapshot<Map<String, dynamic>> ticketSnapshot = await q.get();
    if (ticketSnapshot.size == 0) {
      return [];
    } else {
      ticketSnapshot.docs.forEach((ticketDoc) {
        Ticket ticket;
        try {
          ticket = Ticket.fromMap(id: ticketDoc.id, event: event, release: null, data: ticketDoc.data());
          try {
            ticket.release = event.getRelease(ticketDoc.get("ticket_release_id"));

            tickets.add(ticket);
          } catch (_) {
            // From the old version, tickets won't have a ticket_release_id
            // All our tickets should be single restricted so this should work until there are no more old tickets
            if (ticket.release == null) {
              ticket.release = event.getReleasesWithSingleTicketRestriction()[0];
            }
            tickets.add(ticket);
          }
        } catch (e, s) {
          BugsnagNotifier.instance.notify("Error loading tickets \n $e", s, severity: ErrorSeverity.error);
          print(e);
          print(s);
        }
      });
      return tickets;
    }
  }

  /// Paid ticket processing
  /// Creates tickets for the user and stores it in the user's 'ticket' subcollection and in the ticketevent's 'tickets' subcollection
  /// Calls a cloud function to handle the confirmation email.
  Future<List<Ticket>> issueTickets(Event event, TicketRelease release, int quantity, Discount? discount) async {
    try {
      List<String> ticketDocIds = [];
      List<Ticket> tickets = [];
      for (int i = 0; i < quantity; i++) {
        Ticket ticket = Ticket()
          ..dateIssued = DateTime.now()
          ..event = event;

        DocumentReference ticketDoc =
            await FirebaseFirestore.instance.collection("ticketevents").doc(event.docID).collection("tickets").add({
          "eventref": event.docID,
          "venueref": event.venue,
          "eventdate": event.date,
          "eventname": event.name,
          "imageURL": event.coverImageURL,
          "type": LinkRepository.instance.linkType.dbString,
          "ticketnumber": i,
          "valid": true,
          "requestee": UserRepository.instance.currentUser()!.firebaseUserID,
          "requesttime": ticket.dateIssued,
          "useremail": UserRepository.instance.currentUser()!.email,
          "firstname": UserRepository.instance.currentUser()!.firstname,
          "lastname": UserRepository.instance.currentUser()!.lastname,
          "dob": UserRepository.instance.currentUser()!.dob,
          "gender": UserRepository.instance.currentUser()!.gender!.toDBString(),
          if (LinkRepository.instance.linkType is Invitation)
            "promoter": (LinkRepository.instance.linkType as Invitation).promoter!.docId,
          if (LinkRepository.instance.linkType is AdvertisementLink)
            "advertisement_id": (LinkRepository.instance.linkType as AdvertisementLink).advertisementId,
          if (discount != null) "discount_id": discount.docId,
          "onWaitList": false,
          "venuename": event.venueName,
          "ticket_release_id": release.docId
        });

        FirebaseFirestore.instance
            .collection("users")
            .doc(UserRepository.instance.currentUser()!.firebaseUserID)
            .collection("tickets")
            .doc(ticketDoc.id)
            .set({
          "eventref": event.docID,
          "eventdate": event.date,
          "eventname": event.name,
          "imageURL": event.coverImageURL,
          "type": LinkRepository.instance.linkType.dbString,
          "ticketnumber": i,
          "valid": true,
          "requesttime": ticket.dateIssued,
          if (LinkRepository.instance.linkType is Invitation)
            "promoter": (LinkRepository.instance.linkType as Invitation).promoter!.docId,
          if (LinkRepository.instance.linkType is AdvertisementLink)
            "advertisement_id": (LinkRepository.instance.linkType as AdvertisementLink).advertisementId,
          "onWaitList": false,
          "venuename": event.venueName,
          "ticket_release_id": release.docId
        });
        ticketDocIds.add(ticketDoc.id);
        ticket.docId = ticketDoc.id;
        ticket.release = release;
        tickets.add(ticket);
      }
      incrementLinkTicketsBoughtCounter(event, quantity);
      incrementTicketCounter(event, release, quantity);

      if (discount != null) {
        incrementDiscountCounter(event, discount, quantity);
      }

      http.Response response;
      try {
        response = await http.post(Uri.parse("https://appollo-devops.web.app/ticketConfirmation"), body: {
          "uid": UserRepository.instance.currentUser()!.firebaseUserID,
          "eventId": event.docID,
          "ticketId": ticketDocIds[0]
        });
        print(response.statusCode);
        print(response.body);
      } on SocketException catch (ex) {
        print(ex);
        BugsnagNotifier.instance
            .notify("Error confirming ticket \n $ex", StackTrace.empty, severity: ErrorSeverity.error);
      }

      return tickets;
    } catch (e, s) {
      BugsnagNotifier.instance.notify("Error during issue tickets \n $e", s, severity: ErrorSeverity.error);
      print(e);
      return [];
    }
  }

  /// Free single ticket (invitation) processing
  /// Creates a ticket for the user and stores it in the user's 'ticket' subcollection and in the ticketevent's 'tickets' subcollection
  /// Calls a cloud function to handle the confirmation email.
  acceptInvitation(Event event, TicketRelease release) async {
    try {
      Ticket ticket = Ticket()
        ..dateIssued = DateTime.now()
        ..event = event;

      DocumentReference ticketDoc =
          await FirebaseFirestore.instance.collection("ticketevents").doc(event.docID).collection("tickets").add({
        "eventref": event.docID,
        "venueref": event.venue,
        "eventdate": event.date,
        "eventname": event.name,
        "imageURL": event.coverImageURL,
        "type": LinkRepository.instance.linkType.dbString,
        "valid": true,
        "requestee": UserRepository.instance.currentUser()!.firebaseUserID,
        "requesttime": ticket.dateIssued,
        "useremail": UserRepository.instance.currentUser()!.email,
        "firstname": UserRepository.instance.currentUser()!.firstname,
        "lastname": UserRepository.instance.currentUser()!.lastname,
        "dob": UserRepository.instance.currentUser()!.dob,
        "gender": UserRepository.instance.currentUser()!.gender!.toDBString(),
        if (LinkRepository.instance.linkType is Invitation)
          "promoter": (LinkRepository.instance.linkType as Invitation).promoter!.docId,
        if (LinkRepository.instance.linkType is AdvertisementLink)
          "advertisement_id": (LinkRepository.instance.linkType as AdvertisementLink).advertisementId,
        "onWaitList": false,
        "venuename": event.venueName,
        "ticket_release_id": release.docId
      });

      await FirebaseFirestore.instance
          .collection("users")
          .doc(UserRepository.instance.currentUser()!.firebaseUserID)
          .collection("tickets")
          .doc(ticketDoc.id)
          .set({
        "eventref": event.docID,
        "eventdate": event.date,
        "eventname": event.name,
        "imageURL": event.coverImageURL,
        "type": LinkRepository.instance.linkType.dbString,
        "valid": true,
        "requesttime": ticket.dateIssued,
        if (LinkRepository.instance.linkType is Invitation)
          "promoter": (LinkRepository.instance.linkType as Invitation).promoter!.docId,
        if (LinkRepository.instance.linkType is AdvertisementLink)
          "advertisement_id": (LinkRepository.instance.linkType as AdvertisementLink).advertisementId,
        "onWaitList": false,
        "venuename": event.venueName,
        "ticket_release_id": release.docId
      });

      incrementLinkAcceptedCounter(event);
      incrementTicketCounter(event, release, 1);

      http.Response response;
      try {
        response = await http.post(Uri.parse("https://appollo-devops.web.app/ticketConfirmation"), body: {
          "uid": UserRepository.instance.currentUser()!.firebaseUserID,
          "eventId": event.docID,
          "ticketId": ticketDoc.id,
          "action": LinkRepository.instance.getCurrentLinkAction()
        });
        print(response.statusCode);
        print(response.body);
      } on SocketException catch (ex) {
        print(ex);
        BugsnagNotifier.instance
            .notify("Error confirming ticket \n $ex", StackTrace.empty, severity: ErrorSeverity.error);
      }

      ticket.docId = ticketDoc.id;
      ticket.release = release;
      return ticket;
    } catch (e, s) {
      BugsnagNotifier.instance.notify("Error accepting invitation \n" + e.toString(), s, severity: ErrorSeverity.error);
      print(e);
      return null;
    }
  }

  Future<List<AttendeeTicket>> loadBookingAttendees(String eventId, String promoterId) async {
    List<AttendeeTicket> attendees = [];
    QuerySnapshot passSnaphot = await FirebaseFirestore.instance
        .collection("ticketevents")
        .doc(eventId)
        .collection("tickets")
        .where("promoter", isEqualTo: promoterId)
        .get();
    await Future.wait(passSnaphot.docs.map((e) async {
      if (!attendees.any((element) => element.docId == e.id)) {
        attendees.add(AttendeeTicket()
          ..docId = e.id
          ..name = e.get("firstname") + " " + e.get("lastname")
          ..dateAccepted = DateTime.fromMillisecondsSinceEpoch(e.get("requesttime").millisecondsSinceEpoch));
      }
    }));
    return attendees;
  }

  /// Increments the bought_ticket counter for releases
  Future<void> incrementTicketCounter(Event event, TicketRelease release, int quantity) async {
    DocumentSnapshot releaseSnapshot = await FirebaseFirestore.instance
        .collection("ticketevents")
        .doc(event.docID)
        .collection("release_managers")
        .doc(event.releaseManagers.firstWhere((element) => element.releases.contains(release)).docId)
        .collection("ticket_releases")
        .doc(release.docId)
        .get();
    if (releaseSnapshot.exists) {
      releaseSnapshot.reference.set({"tickets_bought": FieldValue.increment(quantity)}, SetOptions(merge: true));
    }
  }

  /// Increments the used counter for discounts
  Future<void> incrementDiscountCounter(Event event, Discount discount, int quantity) async {
    DocumentSnapshot releaseSnapshot = await FirebaseFirestore.instance
        .collection("ticketevents")
        .doc(event.docID)
        .collection("discounts")
        .doc(discount.docId)
        .get();
    // If this event offers unlimited free tickets, there won't be a ticket_release
    if (releaseSnapshot.exists) {
      releaseSnapshot.reference.set({"times_used": FieldValue.increment(quantity)}, SetOptions(merge: true));
    }
  }

  incrementLinkOpenedCounter(Event event) async {
    try {
      if (LinkRepository.instance.linkType is AdvertisementLink) {
        AdvertisementLink link = LinkRepository.instance.linkType as AdvertisementLink;
        FirebaseFirestore.instance
            .collection("ticketevents")
            .doc(event.docID)
            .collection("advertisement_links")
            .doc(link.advertisementId)
            .set({"visits": FieldValue.increment(1)}, SetOptions(merge: true));
      }
    } catch (e, s) {
      print(e);
      BugsnagNotifier.instance.notify("Error incrementing link open counter \n $e", s, severity: ErrorSeverity.error);
    }
  }

  incrementLinkAcceptedCounter(Event event) async {
    try {
      if (LinkRepository.instance.linkType is AdvertisementLink) {
        FirebaseFirestore.instance
            .collection("ticketevents")
            .doc(event.docID)
            .collection("advertisement_links")
            .doc((LinkRepository.instance.linkType as AdvertisementLink).advertisementId)
            .set({"completed": FieldValue.increment(1)}, SetOptions(merge: true));
      }
    } catch (e, s) {
      print(e);
      BugsnagNotifier.instance
          .notify("Error incrementing link accepted counter \n $e", s, severity: ErrorSeverity.error);
    }
  }

  incrementLinkTicketsBoughtCounter(Event event, int quantity) async {
    try {
      if (LinkRepository.instance.linkType is AdvertisementLink) {
        FirebaseFirestore.instance
            .collection("ticketevents")
            .doc(event.docID)
            .collection("advertisement_links")
            .doc((LinkRepository.instance.linkType as AdvertisementLink).advertisementId)
            .set({"completed": FieldValue.increment(1), "soldTickets": FieldValue.increment(quantity)},
                SetOptions(merge: true));
      }
    } catch (e, s) {
      print(e);
      BugsnagNotifier.instance
          .notify("Error incrementing tickets bought counter \n $e", s, severity: ErrorSeverity.error);
    }
  }

  /// Local data can be old, therefore check if the tickets are actually still available before purchase
  Future<bool> checkTicketsStillAvailable(Event event, Map<TicketRelease, int> paidReleases) async {
    List<Future<DocumentSnapshot>> responses = [];
    try {
      paidReleases.forEach((key, value) {
        responses.add(FirebaseFirestore.instance
            .collection("ticketevents")
            .doc(event.docID)
            .collection("release_managers")
            .doc(event.getReleaseManager(key)!.docId)
            .collection("ticket_releases")
            .doc(key.docId)
            .get(GetOptions(source: Source.server)));
      });
    } catch (e, s) {
      BugsnagNotifier.instance.notify("Couldn't check available tickets. $e", s);
      return false;
    }
    List<DocumentSnapshot> ticketReleases = await Future.wait(responses);
    for (int i = 0; i < ticketReleases.length; i++) {
      try {
        // Update the local data on bought tickets to reflect the data we just got.
        event.getRelease(ticketReleases[i].id)!.ticketsBought = ticketReleases[i].get("tickets_bought");

        if (ticketReleases[i].get("max_tickets") <
            ticketReleases[i].get("tickets_bought") +
                paidReleases[paidReleases.keys.firstWhere((element) => element.docId == ticketReleases[i].id)]) {
          return false;
        }
      } catch (e, s) {
        print(e);
        BugsnagNotifier.instance.notify("Couldn't check available tickets. $e", s);
        return false;
      }
    }

    return true;
  }

  /// Local data can be old, therefore check if the discounts are actually still available before purchase
  Future<bool> checkDiscountsStillAvailable(Event event, Discount discount, int numTickets) async {
    DocumentSnapshot<Map<String, dynamic>> discountSnap = await FirebaseFirestore.instance
        .collection("ticketevents")
        .doc(event.docID)
        .collection("discounts")
        .doc(discount.docId)
        .get();
    try {
      if (discountSnap.exists && discountSnap.get("max_uses") >= discountSnap.get("times_used") + numTickets) {
        return true;
      } else {
        return false;
      }
    } catch (e, s) {
      BugsnagNotifier.instance.notify("Couldn't check discount availability $e", s);
      return false;
    }
  }
}
