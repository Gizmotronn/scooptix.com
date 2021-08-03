import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ticketapp/services/bugsnag_wrapper.dart';
import '../model/event.dart';
import '../model/release_manager.dart';
import '../model/ticket_release.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/model/release_manager.dart';
import 'package:ticketapp/model/ticket_release.dart';

class EventsRepository {
  static EventsRepository? _instance;

  static EventsRepository get instance {
    if (_instance == null) {
      _instance = EventsRepository._();
    }
    return _instance!;
  }

  EventsRepository._();

  dispose() {
    events.clear();
    _instance = null;
  }

  List<Event> events = [];

  List<Event> get upcomingPublicEvents => events
      .where((element) => !element.isPrivateEvent && element.date.isAfter(DateTime.now().subtract(Duration(hours: 8))))
      .toList();

  Future<Event?> loadEventById(String id) async {
    try {
      return events.firstWhere((element) => element.docID == id);
    } catch (_) {
      print("could not find event with id $id");
    }
    print(id);
    DocumentSnapshot<Map<String, dynamic>> eventSnapshot =
        await FirebaseFirestore.instance.collection("events").doc(id).get();
    DocumentSnapshot<Map<String, dynamic>> ticketEventSnapshot =
        await FirebaseFirestore.instance.collection("ticketevents").doc(id).get();

    if (!eventSnapshot.exists || !ticketEventSnapshot.exists) {
      BugsnagNotifier.instance.notify("Couldn't load event $id", StackTrace.current);
      return null;
    }

    QuerySnapshot<Map<String, dynamic>> releaseManagerSnapshot =
        await FirebaseFirestore.instance.collection("ticketevents").doc(id).collection("release_managers").get();

    try {
      Event event = Event.fromMap(eventSnapshot.id, eventSnapshot.data()!);

      event.feePercent =
          ticketEventSnapshot.data()!.containsKey("fee_percent") ? ticketEventSnapshot.get("fee_percent") : 10.0;

      await Future.wait(releaseManagerSnapshot.docs.map((element) async {
        ReleaseManager rm = ReleaseManager.fromMap(element.id, element.data());
        rm.releases.addAll(await EventsRepository.instance.loadReleasesForManager(event.docID!, rm));
        event.releaseManagers.add(rm);
      }));

      events.add(event);

      return event;
    } catch (_) {
      return null;
    }
  }

  List<Event> getRecurringEvents(String recurringEventId) {
    try {
      return events.where((element) => element.recurringEventId == recurringEventId).toList();
    } catch (_) {
      return [];
    }
  }

  Future<Event?> loadNextRecurringEvent(String recurringEventId) async {
    List<Event> recurringEvents = getRecurringEvents(recurringEventId);
    if (recurringEvents.any((element) => element.recurringEventId == recurringEventId)) {
      List<Event> recEvents = recurringEvents.where((element) => element.recurringEventId == recurringEventId).toList();
      recEvents.sort((a, b) => a.date.isBefore(b.date) ? -1 : 1);
      return recEvents[0];
    } else {
      QuerySnapshot recEvent = await FirebaseFirestore.instance
          .collection("events")
          .where("recurring_event_id", isEqualTo: recurringEventId)
          .where("date", isGreaterThan: DateTime.now())
          .orderBy("date")
          .limit(1)
          .get();
      if (recEvent.size > 0) {
        return await loadEventById(recEvent.docs[0].id);
      } else {
        return null;
      }
    }
  }

  /// Loads all TicketReleases for the given release manager. Should be used to load releases for ReleaseManagers
  Future<List<TicketRelease>> loadReleasesForManager(String eventId, ReleaseManager rm) async {
    QuerySnapshot<Map<String, dynamic>> releaseSnapshots = await FirebaseFirestore.instance
        .collection("ticketevents")
        .doc(eventId)
        .collection("release_managers")
        .doc(rm.docId)
        .collection("ticket_releases")
        .get();

    List<TicketRelease> ticketReleases = [];
    releaseSnapshots.docs.forEach((releaseDoc) {
      try {
        TicketRelease release = TicketRelease.fromMap(releaseDoc.id, releaseDoc.data(), rm.name!);
        ticketReleases.add(release);
      } catch (_) {}
    });

    return ticketReleases;
  }

  /// Fetches all upcoming events from the database
  /// Events are also cached in [events] and can be accessed there if sure the required events are already loaded
  Future<List<Event>> loadUpcomingEvents() async {
    QuerySnapshot<Map<String, dynamic>> eventsSnapshot = await FirebaseFirestore.instance
        .collection("events")
        .where("date", isGreaterThanOrEqualTo: DateTime.now().subtract(Duration(hours: 8)))
        .where("status", whereIn: ["published", "live", "onsale"]) // Also include events that have recently started
        //.limit(10) // if there are a lot of events, it might make sense to limit the number of events loaded here and load them incrementally when needed.
        .get();

    await Future.wait(eventsSnapshot.docs.map((e) async {
      try {
        Event event = Event.fromMap(e.id, e.data());
        if (!events.any((element) => element.docID == e.id)) {
          FirebaseFirestore.instance.collection("ticketevents").doc(e.id).get().then((ticketEventSnapshot) {
            if (ticketEventSnapshot.exists) {
              event.feePercent = ticketEventSnapshot.data()!.containsKey("fee_percent")
                  ? ticketEventSnapshot.get("fee_percent")
                  : 10.0;
            }
          });

          QuerySnapshot<Map<String, dynamic>> releaseManagerSnapshot = await FirebaseFirestore.instance
              .collection("ticketevents")
              .doc(e.id)
              .collection("release_managers")
              .get();

          await Future.wait(releaseManagerSnapshot.docs.map((element) async {
            ReleaseManager rm = ReleaseManager.fromMap(element.id, element.data());
            rm.releases.addAll(await EventsRepository.instance.loadReleasesForManager(event.docID!, rm));
            event.releaseManagers.add(rm);
          }));
          events.add(event);
        }
      } catch (_) {}
    }));

    return events;
  }
}
