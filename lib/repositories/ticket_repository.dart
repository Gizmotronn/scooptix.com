import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webapp/model/discount.dart';
import 'package:webapp/model/event.dart';
import 'package:webapp/model/link_type/advertisementInvite.dart';
import 'package:webapp/model/link_type/invitation.dart';
import 'package:webapp/model/link_type/link_type.dart';
import 'package:webapp/model/link_type/promoterInvite.dart';
import 'package:webapp/model/ticket.dart';
import 'package:webapp/model/ticket_release.dart';
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

  Future<Discount> loadDiscount(Event event, String code) async {
    QuerySnapshot discountSnapshot = await FirebaseFirestore.instance
        .collection("ticketevents")
        .doc(event.docID)
        .collection("discounts")
        .where("code", isEqualTo: code)
        .get();
    if (discountSnapshot.size == 0) {
      return null;
    } else {
      return Discount.fromMap(discountSnapshot.docs[0].id, discountSnapshot.docs[0].data());
    }
  }

  Future<List<Ticket>> loadTickets(String uid, Event event) async {
    List<Ticket> tickets = [];
    QuerySnapshot ticketSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("tickets")
        .where("eventref", isEqualTo: event.docID)
        .get();
    print("num tickets ${ticketSnapshot.size}");
    if (ticketSnapshot.size == 0) {
      return [];
    } else {
      ticketSnapshot.docs.forEach((ticketDoc) {
        Ticket ticket;
        try {
          ticket = Ticket()
            ..event = event
            ..docId = ticketDoc.id
            ..dateIssued = DateTime.fromMillisecondsSinceEpoch(ticketDoc.data()["requesttime"].millisecondsSinceEpoch);
          try {
            print("option 1");
            ticket.release = event.getRelease(ticketDoc.data()["ticket_release_id"]);

            tickets.add(ticket);
          } catch (_) {
            // From the old version, tickets won't have a ticket_release_id
            // All our tickets should be single restricted so this should work until there are no more old tickets
            if (ticket.release == null) {
              print("get single release");
              ticket.release = event.getReleasesWithSingleTicketRestriction()[0];
            }
            tickets.add(ticket);
          }
        } catch (e, s) {
          BugsnagNotifier.instance.notify(e, s, severity: ErrorSeverity.error);
          print(e);
        }
      });
      return tickets;
    }
  }

  /// Paid ticket processing
  /// Creates tickets for the user and stores it in the user's 'ticket' subcollection and in the ticketevent's 'tickets' subcollection
  /// Calls a cloud function to handle the confirmation email.
  Future<List<Ticket>> issueTickets(LinkType linkType, TicketRelease release, int quantity, Discount discount) async {
    try {
      List<String> ticketDocIds = [];
      List<Ticket> tickets = [];
      for (int i = 0; i < quantity; i++) {
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
          "ticketnumber": i,
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
          if (discount != null) "discount_id": discount.docId,
          "onWaitList": false,
          "venuename": linkType.event.venueName,
          "ticket_release_id": release.docId
        });

        FirebaseFirestore.instance
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
          "ticketnumber": i,
          "valid": true,
          "requesttime": ticket.dateIssued,
          if (linkType is Invitation) "promoter": linkType.promoter.docId,
          if (linkType is AdvertisementInvite) "advertisement_id": linkType.advertisementId,
          "onWaitList": false,
          "venuename": linkType.event.venueName,
          "ticket_release_id": release.docId
        });
        ticketDocIds.add(ticketDoc.id);
        ticket.docId = ticketDoc.id;
        ticket.release = release;
        tickets.add(ticket);
      }
      incrementLinkTicketsBoughtCounter(linkType, quantity);
      incrementTicketCounter(linkType.event, release, quantity);
      if (discount != null) {
        incrementDiscountCounter(linkType.event, discount, quantity);
      }

      http.Response response;
      try {
        response = await http.post("https://appollo-devops.web.app/ticketConfirmation", body: {
          "uid": UserRepository.instance.currentUser.firebaseUserID,
          "eventId": linkType.event.docID,
          "ticketId": ticketDocIds[0]
        });
        print(response.statusCode);
        print(response.body);
      } on SocketException catch (ex) {
        print(ex);
        BugsnagNotifier.instance.notify(ex, StackTrace.empty, severity: ErrorSeverity.error);
      }

      return tickets;
    } catch (e, s) {
      BugsnagNotifier.instance.notify(e, s, severity: ErrorSeverity.error);
      print(e);
      return [];
    }
  }

  /// Free single ticket (invitation) processing
  /// Creates a ticket for the user and stores it in the user's 'ticket' subcollection and in the ticketevent's 'tickets' subcollection
  /// Calls a cloud function to handle the confirmation email.
  acceptInvitation(LinkType linkType, TicketRelease release) async {
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
        "ticket_release_id": release.docId
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
        "ticket_release_id": release.docId
      });

      incrementLinkAcceptedCounter(linkType);
      incrementTicketCounter(linkType.event, release, 1);

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
        BugsnagNotifier.instance.notify(ex, StackTrace.empty, severity: ErrorSeverity.error);
      }

      ticket.docId = ticketDoc.id;
      ticket.release = release;
      return ticket;
    } catch (e, s) {
      BugsnagNotifier.instance.notify(e, s, severity: ErrorSeverity.error);
      print(e);
      return null;
    }
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
    // If this event offers unlimited free tickets, there won't be a ticket_release
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

  incrementLinkTicketsBoughtCounter(LinkType linkType, int quantity) async {
    try {
      if (linkType is PromoterInvite) {
        FirebaseFirestore.instance.collection("promoters").doc(linkType.promoter.docId).set({
          "events": {
            linkType.event.docID: {"soldTickets": FieldValue.increment(quantity)}
          }
        }, SetOptions(merge: true));
      } else if (linkType is AdvertisementInvite) {
        FirebaseFirestore.instance
            .collection("ticketevents")
            .doc(linkType.event.docID)
            .collection("advertisement_links")
            .doc(linkType.advertisementId)
            .set({"completed": FieldValue.increment(1), "soldTickets": FieldValue.increment(quantity)},
                SetOptions(merge: true));
      }
    } catch (e, s) {
      print(e);
      BugsnagNotifier.instance.notify(e, s, severity: ErrorSeverity.error);
    }
  }
}
