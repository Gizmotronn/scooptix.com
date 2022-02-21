import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:ticketapp/model/birthday_lists/attendee.dart';
import 'package:ticketapp/model/discount.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/model/link_type/advertisement_invite.dart';
import 'package:ticketapp/model/ticket.dart';
import 'package:ticketapp/model/ticket_release.dart';
import 'package:ticketapp/repositories/events_repository.dart';
import 'package:ticketapp/repositories/link_repository.dart';
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

  /// Free single ticket (invitation) processing
  /// Creates a ticket for the user and stores it in the user's 'ticket' subcollection and in the ticketevent's 'tickets' subcollection
  /// Calls a cloud function to handle the confirmation email.
  acceptInvitation(Event event, TicketRelease release) async {
    try {
      Ticket ticket = Ticket()
        ..dateIssued = DateTime.now()
        ..event = event;

      incrementLinkAcceptedCounter(event);

      HttpsCallable callable = FirebaseFunctions.instance
          .httpsCallable('issueTickets', options: HttpsCallableOptions(timeout: Duration(seconds: 15)));
      final results = await callable({
        "eventId": event.docID,
        "quantity": 1,
        "releaseId": release.docId,
        "managerId": event.getReleaseManager(release)!.docId,
        "action": LinkRepository.instance.getCurrentLinkAction()
      });

      if (results.data["valid"] == true && results.data["ticketIds"].length > 0) {
        ticket.docId = results.data["ticketIds"][0];
        ticket.release = release;
        return ticket;
      } else {
        return null;
      }
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
