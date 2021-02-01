import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webapp/model/event.dart';
import 'package:webapp/model/link_type/advertisementInvite.dart';
import 'package:webapp/model/link_type/birthdayList.dart';
import 'package:webapp/model/link_type/link_type.dart';
import 'package:webapp/model/link_type/promoterInvite.dart';
import 'package:webapp/model/release_manager.dart';
import 'package:webapp/model/ticket_release.dart';
import 'package:webapp/repositories/user_repository.dart';
import 'package:webapp/services/bugsnag_wrapper.dart';

class EventsRepository {
  static EventsRepository _instance;

  static EventsRepository get instance {
    if (_instance == null) {
      _instance = EventsRepository._();
    }
    return _instance;
  }

  EventsRepository._();

  dispose() {
    _instance = null;
  }

  List<Event> events = List<Event>();

  Future<Event> loadEventById(String id) async {
    print(id);
    DocumentSnapshot eventSnapshot = await FirebaseFirestore.instance.collection("events").doc(id).get();
    // DocumentSnapshot ticketEventSnapshot = await FirebaseFirestore.instance.collection("ticketevents").doc(id).get();

    QuerySnapshot releaseManagerSnapshot =
        await FirebaseFirestore.instance.collection("ticketevents").doc(id).collection("release_managers").get();

    Event event = Event.fromMap(eventSnapshot.id, eventSnapshot.data());

    await Future.wait(releaseManagerSnapshot.docs.map((element) async {
      ReleaseManager rm = ReleaseManager.fromMap(element.id, element.data());
      rm.releases.addAll(await EventsRepository.instance.loadReleasesForManager(event.docID, rm.releaseIds));
      rm.releases.forEach((TicketRelease tr) {
        if(tr.maxTickets > tr.ticketsBought
            && tr.releaseStart.isBefore(DateTime.now())
            && tr.releaseEnd.isAfter(DateTime.now())){
          rm.activeReleases.add(tr);
        }
      });
      event.releaseManagers.add(rm);
    }));


    return event;
  }

  Future<List<Event>> loadFutureEventsWithBDaySignUps() async {
    if (events.length == 0) {
      QuerySnapshot eventSnapshot = await FirebaseFirestore.instance
          .collection("events")
          .where("date", isGreaterThan: DateTime.now())
          .where("allowsbirthdaysignups", isEqualTo: true)
          .get();
      eventSnapshot.docs.forEach((eventDoc) {
        Event event = Event.fromMap(eventDoc.id, eventDoc.data());
        if (event != null) {
          events.add(event);
        }
      });
    }

    return events;
  }


  /// Loads all TicketReleases for given releaseIds. Should be used to load releases for ReleaseManagers
  Future<List<TicketRelease>> loadReleasesForManager(String eventId, List<String> releaseIds) async {
    List<DocumentSnapshot> releaseSnapshots = [];

    await Future.wait(releaseIds.map((releaseId) async {
      releaseSnapshots.add(await FirebaseFirestore.instance
          .collection("ticketevents")
          .doc(eventId)
          .collection("ticket_releases")
          .doc(releaseId)
          .get());
    }));

    List<TicketRelease> ticketReleases = [];
    releaseSnapshots.forEach((releaseDoc) {
      TicketRelease release = TicketRelease.fromMap(releaseDoc.id, releaseDoc.data());
      if (release != null) {
        ticketReleases.add(release);
      }
    });

    return ticketReleases;
  }

  Future<LinkType> loadLinkType(String uuid) async {
    try {
      QuerySnapshot uuidMapSnapshot =
          await FirebaseFirestore.instance.collection("uuidmap").where("uuid", isEqualTo: uuid).get();
      if (uuidMapSnapshot.size > 0) {
        LinkTypes lt = LinkTypes.Promoter;
        try {
          lt = LinkTypes.values.firstWhere((element) => element.toDBString() == uuidMapSnapshot.docs[0].data()["type"]);
        } catch (_) {
          // In case there is no type for some reason
        }
        LinkType linkType;
        switch (lt) {
          case LinkTypes.Promoter:
            linkType = PromoterInvite()
              ..uuid = uuid
              ..promoter = await UserRepository.instance.loadPromoter(uuidMapSnapshot.docs[0].data()["promoter"])
              ..event = await loadEventById(uuidMapSnapshot.docs[0].data()["event"]);
            break;
          case LinkTypes.BirthdayList:
            linkType = BirthdayList()
              ..uuid = uuid
              ..promoter = await UserRepository.instance.loadPromoter(uuidMapSnapshot.docs[0].data()["promoter"])
              ..event = await loadEventById(uuidMapSnapshot.docs[0].data()["event"]);
            break;
          case LinkTypes.Ticket:
            // TODO: Handle this case.
            break;
          case LinkTypes.Advertisement:
            linkType = AdvertisementInvite()
              ..uuid = uuid
              ..advertisementId = uuidMapSnapshot.docs[0].data()["advertisement_id"]
              ..event = await loadEventById(uuidMapSnapshot.docs[0].data()["event"]);
            break;
        }
        return linkType;
      } else {
        return null;
      }
    } catch (e, s) {
      print(e);
      BugsnagNotifier.instance.notify(e, s, severity: ErrorSeverity.error);
      return null;
    }
  }
}
