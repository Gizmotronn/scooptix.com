import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webapp/model/event.dart';
import 'package:webapp/model/link_type/invitation.dart';
import 'package:webapp/model/link_type/link_type.dart';
import 'package:webapp/model/link_type/promoterInvite.dart';
import 'package:webapp/model/ticket.dart';
import 'package:webapp/repositories/user_repository.dart';
import 'package:http/http.dart' as http;

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
      } catch (e) {
        print(e);
      }
      return ticket;
    }
  }

  /// Creates a tickets for the user and stores it in the user's 'ticket' subcollection and in the ticketevent's 'tickets' subcollection
  /// Calls a cloud function to handle the confirmation email.
  acceptInvitation(Invitation invitation) async {
    try {
      Ticket ticket = Ticket()
        ..dateIssued = DateTime.now()
        ..event = invitation.event;

      DocumentReference ticketDoc = await FirebaseFirestore.instance
          .collection("ticketevents")
          .doc(invitation.event.docID)
          .collection("tickets")
          .add({
        "eventref": invitation.event.docID,
        "venueref": invitation.event.venue,
        "eventdate": invitation.event.date,
        "eventname": invitation.event.name,
        "imageURL": invitation.event.coverImageURL,
        "type": invitation.toString(),
        "valid": true,
        "requestee": UserRepository.instance.currentUser.firebaseUserID,
        "requesttime": ticket.dateIssued,
        "useremail": UserRepository.instance.currentUser.email,
        "firstname": UserRepository.instance.currentUser.firstname,
        "lastname": UserRepository.instance.currentUser.lastname,
        "promoter": invitation.promoter.docId,
        "onWaitList": false,
        "venuename": invitation.event.venueName,
      });

      await FirebaseFirestore.instance
          .collection("users")
          .doc(UserRepository.instance.currentUser.firebaseUserID)
          .collection("tickets")
          .doc(ticketDoc.id)
          .set({
        "eventref": invitation.event.docID,
        "eventdate": invitation.event.date,
        "eventname": invitation.event.name,
        "imageURL": invitation.event.coverImageURL,
        "type": invitation.toString(),
        "valid": true,
        "requesttime": ticket.dateIssued,
        "promoter": invitation.promoter.docId,
        "onWaitList": false,
        "venuename": invitation.event.venueName,
      });

      incrementPromoterLinkAcceptedCounter(invitation);
      incrementFreeTicketCounter(invitation.event.docID);

      http.Response response;
      try {
        response = await http.post("https://appollo-devops.web.app/ticketConfirmation", body: {
          "uid": UserRepository.instance.currentUser.firebaseUserID,
          "eventId": invitation.event.docID,
          "ticketId": ticketDoc.id
        });
        print(response.statusCode);
        print(response.body);
      } on SocketException catch (ex) {
        print(ex);
      }

      return ticket;
    } catch (e) {
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
    } catch (e) {
      print(e);
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

  incrementPromoterLinkOpenedCounter(LinkType linkType) async {
    try {
      if (linkType is PromoterInvite) {
        FirebaseFirestore.instance.collection("promoters").doc(linkType.promoter.docId).set({
          "events": {
            linkType.event.docID: {"linkOpened": FieldValue.increment(1)}
          }
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print(e);
    }
  }

  incrementPromoterLinkAcceptedCounter(LinkType linkType) async {
    try {
      if (linkType is PromoterInvite) {
        FirebaseFirestore.instance.collection("promoters").doc(linkType.promoter.docId).set({
          "events": {
            linkType.event.docID: {"acceptedInvites": FieldValue.increment(1)}
          }
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print(e);
    }
  }
}
