import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webapp/model/event.dart';
import 'package:webapp/model/link_type/birthdayList.dart';
import 'package:webapp/model/link_type/link_type.dart';
import 'package:webapp/model/link_type/promoterInvite.dart';
import 'package:webapp/repositories/user_repository.dart';

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
    QuerySnapshot ticketReleasesSnapshot =
        await FirebaseFirestore.instance.collection("ticketevents").doc(id).collection("ticket_releases").get();
    QuerySnapshot releaseManagerSnapshot =
        await FirebaseFirestore.instance.collection("ticketevents").doc(id).collection("release_managers").get();

    Event event = Event.fromMap(eventSnapshot.id, eventSnapshot.data());

    /*ticketReleasesSnapshot.docs.forEach((element) {
      event.releases.add(TicketRelease.fromMap(element.id, element.data()));
    });
    releaseManagerSnapshot.docs.forEach((element) {
      ReleaseManager rm = ReleaseManager.fromMap(element.id, element.data());
      rm.releaseIds.forEach((id) {
        rm.releases.add(event.releases.firstWhere((release) => release.docId == id));
      });
      event.releaseManagers.add(rm);
    });*/

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
        }
        return linkType;
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }
}
