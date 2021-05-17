import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/event.dart';
import '../model/release_manager.dart';
import '../model/ticket_release.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/model/release_manager.dart';
import 'package:ticketapp/model/ticket_release.dart';

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

  List<Event> events = <Event>[];

  Future<Event> loadEventById(String id) async {
    print(id);
    DocumentSnapshot eventSnapshot = await FirebaseFirestore.instance.collection("events").doc(id).get();
    DocumentSnapshot ticketEventSnapshot = await FirebaseFirestore.instance.collection("ticketevents").doc(id).get();

    QuerySnapshot releaseManagerSnapshot =
        await FirebaseFirestore.instance.collection("ticketevents").doc(id).collection("release_managers").get();

    Event event = Event.fromMap(eventSnapshot.id, eventSnapshot.data());

    if (event != null) {
      event.feePercent =
          ticketEventSnapshot.data().containsKey("fee_percent") ? ticketEventSnapshot.data()["fee_percent"] : 10.0;
    }
    await Future.wait(releaseManagerSnapshot.docs.map((element) async {
      ReleaseManager rm = ReleaseManager.fromMap(element.id, element.data());
      rm.releases.addAll(await EventsRepository.instance.loadReleasesForManager(event.docID, rm));
      event.releaseManagers.add(rm);
    }));

    return event;
  }

  List<Event> getRecurringEvents(String recurringEventId) {
    return events.where((element) => element.recurringEventId == recurringEventId).toList();
  }

  /// Loads all TicketReleases for the given release manager. Should be used to load releases for ReleaseManagers
  Future<List<TicketRelease>> loadReleasesForManager(String eventId, ReleaseManager rm) async {
    QuerySnapshot releaseSnapshots = await FirebaseFirestore.instance
        .collection("ticketevents")
        .doc(eventId)
        .collection("release_managers")
        .doc(rm.docId)
        .collection("ticket_releases")
        .get();

    List<TicketRelease> ticketReleases = [];
    releaseSnapshots.docs.forEach((releaseDoc) {
      TicketRelease release = TicketRelease.fromMap(releaseDoc.id, releaseDoc.data(), rm.name);
      if (release != null) {
        ticketReleases.add(release);
      }
    });

    return ticketReleases;
  }

  /// Fetches all upcoming events from the database
  /// Events are also cached in [events] and can be accessed there if sure the required events are already loaded
  Future<List<Event>> loadUpcomingEvents() async {
    QuerySnapshot eventsSnapshot = await FirebaseFirestore.instance
        .collection("events")
        .where("date",
            isGreaterThanOrEqualTo:
                DateTime.now().subtract(Duration(hours: 8))) // Also include events that have recently started
        //.limit(10) // if there are a lot of events, it might make sense to limit the number of events loaded here and load them incrementally when needed.
        .get();
    await Future.wait(eventsSnapshot.docs.map((e) async {
      Event event = Event.fromMap(e.id, e.data());
      if (event != null && !events.any((element) => element.docID == e.id)) {
        DocumentSnapshot ticketEventSnapshot =
            await FirebaseFirestore.instance.collection("ticketevents").doc(e.id).get();

        QuerySnapshot releaseManagerSnapshot =
            await FirebaseFirestore.instance.collection("ticketevents").doc(e.id).collection("release_managers").get();

        if (ticketEventSnapshot.exists) {
          event.feePercent =
              ticketEventSnapshot.data().containsKey("fee_percent") ? ticketEventSnapshot.data()["fee_percent"] : 10.0;
        }
        await Future.wait(releaseManagerSnapshot.docs.map((element) async {
          ReleaseManager rm = ReleaseManager.fromMap(element.id, element.data());
          rm.releases.addAll(await EventsRepository.instance.loadReleasesForManager(event.docID, rm));
          event.releaseManagers.add(rm);
        }));
        events.add(event);
      }
    }));

    return events;
  }
}
