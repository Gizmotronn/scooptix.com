import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webapp/model/event.dart';
import 'package:webapp/model/link_type/advertisementInvite.dart';
import 'package:webapp/model/link_type/invitation.dart';
import 'package:webapp/model/link_type/link_type.dart';
import 'package:webapp/model/link_type/promoterInvite.dart';
import 'package:webapp/model/ticket.dart';
import 'package:webapp/model/user.dart';
import 'package:webapp/repositories/user_repository.dart';
import 'package:http/http.dart' as http;
import 'package:webapp/services/bugsnag_wrapper.dart';

class TicketRepository {
  static TicketRepository _instance;

  static TicketRepository get instance {
    if (_instance == null) {
      _instance = TicketRepository._();
    }
    return _instance;
  }

  TicketRepository._();

  dispose() {
    _instance = null;
  }

  Future<Ticket> loadTicket(String uid, Event event) async {
    QuerySnapshot ticketSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("tickets")
        .where("eventref", isEqualTo: event.docID)
        .get();
    if (ticketSnapshot.size == 0) {
      return null;
    } else {
      Ticket ticket;
      try {
        ticket = Ticket()
          ..event = event
          ..dateIssued =
              DateTime.fromMillisecondsSinceEpoch(ticketSnapshot.docs[0].data()["requesttime"].millisecondsSinceEpoch);
      } catch (e, s) {
        print(e);
        BugsnagNotifier.instance.notify(e, s, severity: ErrorSeverity.error);
      }
      return ticket;
    }
  }

  /// Creates a tickets for the user and stores it in the user's 'ticket' subcollection and in the ticketevent's 'tickets' subcollection
  /// Calls a cloud function to handle the confirmation email.
  acceptInvitation(LinkType linkType) async {
    try {
      Ticket ticket = Ticket()
        ..dateIssued = DateTime.now()
        ..event = linkType.event;

      DocumentReference ticketDoc = await FirebaseFirestore.instance
          .collection("ticketevents")
          .doc(linkType.event.docID)
          .collection("tickets")
          .add({
        "eventref": linkType.event.docID,
        "venueref": linkType.event.venue,
        "eventdate": linkType.event.date,
        "eventname": linkType.event.name,
        "imageURL": linkType.event.coverImageURL,
        "type": linkType.toString(),
        "valid": true,
        "requestee": UserRepository.instance.currentUser.firebaseUserID,
        "requesttime": ticket.dateIssued,
        "useremail": UserRepository.instance.currentUser.email,
        "firstname": UserRepository.instance.currentUser.firstname,
        "lastname": UserRepository.instance.currentUser.lastname,
        "dob": UserRepository.instance.currentUser.dob,
        "gender": UserRepository.instance.currentUser.gender.toDBString(),
        if (linkType is Invitation) "promoter": linkType.promoter.docId,
        if (linkType is AdvertisementInvite) "advertisement_id": linkType.advertisementId,
        "onWaitList": false,
        "venuename": linkType.event.venueName,
      });

      await FirebaseFirestore.instance
          .collection("users")
          .doc(UserRepository.instance.currentUser.firebaseUserID)
          .collection("tickets")
          .doc(ticketDoc.id)
          .set({
        "eventref": linkType.event.docID,
        "eventdate": linkType.event.date,
        "eventname": linkType.event.name,
        "imageURL": linkType.event.coverImageURL,
        "type": linkType.toString(),
        "valid": true,
        "requesttime": ticket.dateIssued,
        if (linkType is Invitation) "promoter": linkType.promoter.docId,
        if (linkType is AdvertisementInvite) "advertisement_id": linkType.advertisementId,
        "onWaitList": false,
        "venuename": linkType.event.venueName,
      });

      incrementLinkAcceptedCounter(linkType);
      incrementFreeTicketCounter(linkType.event.docID);

      http.Response response;
      try {
        response = await http.post("https://appollo-devops.web.app/ticketConfirmation", body: {
          "uid": UserRepository.instance.currentUser.firebaseUserID,
          "eventId": linkType.event.docID,
          "ticketId": ticketDoc.id
        });
        print(response.statusCode);
        print(response.body);
      } on SocketException catch (ex) {
        print(ex);
      }

      return ticket;
    } catch (e, s) {
      BugsnagNotifier.instance.notify(e, s, severity: ErrorSeverity.error);
      print(e);
      return null;
    }
  }

  /// Checks if there are still free tickets left for the given event.
  /// Will always return true if the event has unlimited free tickets.
  Future<bool> freeTicketsLeft(String eventId) async {
    try {
      // There should only ever be 1 release for free events
      QuerySnapshot releaseSnapshot = await FirebaseFirestore.instance
          .collection("ticketevents")
          .doc(eventId)
          .collection("ticket_releases")
          .limit(1)
          .get();
      // If there are 0, this event offers unlimited free tickets
      if (releaseSnapshot.size == 0) {
        return true;
      } else if (releaseSnapshot.docs[0].data()["tickets_bought"] < releaseSnapshot.docs[0].data()["max_tickets"]) {
        return true;
      } else {
        return false;
      }
    } catch (e, s) {
      print(e);
      BugsnagNotifier.instance.notify(e, s, severity: ErrorSeverity.error);
      return false;
    }
  }

  /// Increments the bought_ticket counter for free events
  Future<void> incrementFreeTicketCounter(String eventId) async {
    QuerySnapshot releaseSnapshot = await FirebaseFirestore.instance
        .collection("ticketevents")
        .doc(eventId)
        .collection("ticket_releases")
        .limit(1)
        .get();
    // If this event offers unlimited free tickets, there won't be a ticket_release
    if (releaseSnapshot.size == 1) {
      releaseSnapshot.docs[0].reference.set({"tickets_bought": FieldValue.increment(1)}, SetOptions(merge: true));
    }
  }

  incrementLinkOpenedCounter(LinkType linkType) async {
    try {
      if (linkType is PromoterInvite) {
        FirebaseFirestore.instance.collection("promoters").doc(linkType.promoter.docId).set({
          "events": {
            linkType.event.docID: {"linkOpened": FieldValue.increment(1)}
          }
        }, SetOptions(merge: true));
      } else if (linkType is AdvertisementInvite) {
        FirebaseFirestore.instance
            .collection("ticketevents")
            .doc(linkType.event.docID)
            .collection("advertisement_links")
            .doc(linkType.advertisementId)
            .set({"visits": FieldValue.increment(1)}, SetOptions(merge: true));
      }
    } catch (e, s) {
      print(e);
      BugsnagNotifier.instance.notify(e, s, severity: ErrorSeverity.error);
    }
  }

  incrementLinkAcceptedCounter(LinkType linkType) async {
    try {
      if (linkType is PromoterInvite) {
        FirebaseFirestore.instance.collection("promoters").doc(linkType.promoter.docId).set({
          "events": {
            linkType.event.docID: {"acceptedInvites": FieldValue.increment(1)}
          }
        }, SetOptions(merge: true));
      } else if (linkType is AdvertisementInvite) {
        FirebaseFirestore.instance
            .collection("ticketevents")
            .doc(linkType.event.docID)
            .collection("advertisement_links")
            .doc(linkType.advertisementId)
            .set({"completed": FieldValue.increment(1)}, SetOptions(merge: true));
      }
    } catch (e, s) {
      print(e);
      BugsnagNotifier.instance.notify(e, s, severity: ErrorSeverity.error);
    }
  }
}
