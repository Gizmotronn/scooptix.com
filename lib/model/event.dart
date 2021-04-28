import 'release_manager.dart';
import 'ticket_release.dart';
import 'package:ticketapp/model/release_manager.dart';
import 'package:ticketapp/model/ticket_release.dart';

enum EventOccurrence { Single, Recurring }

extension EventOccurrenceExtension on EventOccurrence {
  String toDBString() {
    return this.toString().split(".")[1].toLowerCase();
  }

  String toDisplayString() {
    return this.toString().split(".")[1];
  }
}

class Event {
  Event._internal();

  String docID;
  String name;
  String description;
  String coverImageURL;
  String address;
  String venue;
  String venueName = "";
  String ticketLink;
  String promoter;
  String organizer;
  String contactEmail;
  String recurringEventId;

  DateTime date;
  DateTime endTime;
  List<String> tags = <String>[];
  List<String> images = <String>[];
  bool isSignedUp = false;
  bool isMockEvent = false;
  bool newPriorityPassesAllowed = false;
  bool newQPassesAllowed = false;
  bool allowsBirthdaySignUps = false;
  List<ReleaseManager> releaseManagers = [];
  int cutoffTimeOffset = 0;
  String invitationMessage = "";
  String ticketCheckoutMessage;
  double feePercent = 10.0;
  EventOccurrence occurrence;

  List<TicketRelease> getTicketReleases() {
    List<TicketRelease> release = [];
    for (int i = 0; i < releaseManagers.length; i++) {
      release.add(releaseManagers[i].getActiveRelease());
    }
    return release;
  }

  // bool getFreeTicket() {
  //   List<int> price = [];
  //   for (int i = 0; i < releaseManagers.length; i++) {
  //     List<TicketRelease> releases = releaseManagers[i].releases;

  //     for (int index = 0; index < releases.length; index++) {
  //      release = releases[index].ticketsLeft();

  //   }
  //   }
  //   return release;
  // }

  bool isTicketSoldOut() {
    bool isSoldOut = false;
    for (int i = 0; i < releaseManagers.length; i++) {
      ReleaseManager manager = releaseManagers[i];
      isSoldOut = manager.releases[0].ticketsLeft() < 1 ? true : false;
    }
    return isSoldOut;
  }

  TicketRelease getRelease(String releaseId) {
    for (int i = 0; i < releaseManagers.length; i++) {
      try {
        TicketRelease tr = releaseManagers[i].releases.firstWhere((element) => element.docId == releaseId);
        return tr;
      } catch (_) {}
    }
    return null;
  }

  List<TicketRelease> getReleasesWithSingleTicketRestriction() {
    List<TicketRelease> releases = [];
    releaseManagers.forEach((manager) {
      if (manager.singleTicketRestriction) {
        releases.add(manager.getActiveRelease());
      }
    });
    return releases;
  }

  List<ReleaseManager> getManagersWithActiveReleases() {
    List<ReleaseManager> activeManagers = [];
    this.releaseManagers.forEach((element) {
      if (element.getActiveRelease() != null) {
        activeManagers.add(element);
      }
    });
    return activeManagers;
  }

  List<TicketRelease> getAllReleases() {
    List<TicketRelease> releases = [];
    releaseManagers.forEach((manager) {
      releases.addAll(manager.releases);
    });
    return releases;
  }

  List<TicketRelease> getActiveReleases() {
    List<TicketRelease> releases = [];
    releaseManagers.forEach((manager) {
      releases.add(manager.getActiveRelease());
    });
    return releases;
  }

  List<TicketRelease> getReleasesWithoutRestriction() {
    List<TicketRelease> releases = [];
    releaseManagers.forEach((manager) {
      if (!manager.singleTicketRestriction) {
        releases.add(manager.getActiveRelease());
      }
    });
    return releases;
  }

  factory Event.fromMap(String docId, Map<String, dynamic> data) {
    try {
      Event event = Event._internal();

      if (data.containsKey("name")) {
        event.name = data["name"];
      }
      if (data.containsKey("description")) {
        event.description = data["description"];
      }
      if (data.containsKey("coverimage")) {
        event.coverImageURL = data["coverimage"];
      }
      if (data.containsKey("address")) {
        event.address = data["address"];
      }
      if (data.containsKey("venue")) {
        event.venue = data["venue"];
      }
      if (data.containsKey("venuename")) {
        event.venueName = data["venuename"];
      }
      if (data.containsKey("ticketlink")) {
        event.ticketLink = data["ticketlink"];
      }
      if (data.containsKey("promoter")) {
        event.promoter = data["promoter"];
      }
      if (data.containsKey("organizer_id")) {
        event.organizer = data["organizer_id"];
      }
      if (data.containsKey("issignedup")) {
        event.isSignedUp = data["issignedup"];
      }
      if (data.containsKey("ismockevent")) {
        event.isMockEvent = data["ismockevent"];
      }
      if (data.containsKey("prioritypassavailable")) {
        event.newPriorityPassesAllowed = data["prioritypassavailable"];
      }
      if (data.containsKey("qpassavailable")) {
        event.newQPassesAllowed = data["qpassavailable"];
      }
      if (data.containsKey("allowsbirthdaysignups")) {
        event.allowsBirthdaySignUps = data["allowsbirthdaysignups"];
      }
      if (data.containsKey("contactemail")) {
        event.contactEmail = data["contactemail"];
      }
      if (data.containsKey("recurring_event_id")) {
        event.recurringEventId = data["recurring_event_id"];
        event.occurrence = EventOccurrence.Recurring;
      } else {
        event.occurrence = EventOccurrence.Single;
      }
      if (data.containsKey("tags")) {
        data["tags"].forEach((s) {
          event.tags.add(s.toString());
        });
      }
      if (data.containsKey("invite_link_cutoff")) {
        event.cutoffTimeOffset = data["invite_link_cutoff"];
      }
      if (data.containsKey("invitation_message")) {
        event.invitationMessage = data["invitation_message"];
      }
      if (data.containsKey("ticket_checkout_message")) {
        event.ticketCheckoutMessage = data["ticket_checkout_message"];
      }
      if (data.containsKey("images")) {
        data["images"].forEach((s) {
          event.images.add(s.toString());
        });
      }
      if (data.containsKey("date")) {
        event.date = DateTime.fromMillisecondsSinceEpoch(data["date"].millisecondsSinceEpoch);
      }
      if (data.containsKey("enddate")) {
        event.endTime = DateTime.fromMillisecondsSinceEpoch(data["enddate"].millisecondsSinceEpoch);
      }
      event.docID = docId;

      return event;
    } catch (e, s) {
      // print(e);
      // BugsnagNotifier.instance.notify(e, s, severity: ErrorSeverity.error);
      return null;
    }
  }
}
