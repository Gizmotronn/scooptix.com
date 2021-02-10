import 'package:webapp/model/release_manager.dart';
import 'package:webapp/model/ticket_release.dart';
import 'package:webapp/services/bugsnag_wrapper.dart';

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
  String repetitionId;
  DateTime date;
  DateTime endTime;
  List<String> tags = List<String>();
  List<String> images = List<String>();
  bool isSignedUp = false;
  bool isMockEvent = false;
  bool newPriorityPassesAllowed = false;
  bool newQPassesAllowed = false;
  bool allowsBirthdaySignUps = false;
  List<ReleaseManager> releaseManagers = [];
  int cutoffTimeOffset = 0;
  String invitationMessage = "";
  String ticketCheckoutMessage;

  TicketRelease getRelease(String releaseId) {
    print(releaseId);
    for (int i = 0; i < releaseManagers.length; i++) {
      try {
        TicketRelease tr = releaseManagers[i].releases.firstWhere((element) => element.docId == releaseId);
        print(tr);
        return tr;
      } catch (_) {}
    }
    return null;
  }

  List<TicketRelease> getReleasesWithSingleTicketRestriction() {
    List<TicketRelease> releases = [];
    releaseManagers.forEach((manager) {
      TicketRelease release = manager.getActiveRelease();
      if (release != null && release.singleTicketRestriction) {
        releases.add(manager.getActiveRelease());
      }
    });
    return releases;
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
      TicketRelease release = manager.getActiveRelease();
      if (release != null && !release.singleTicketRestriction) {
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
      if (data.containsKey("repetition_id")) {
        event.repetitionId = data["repetition_id"];
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
      print(e);
      BugsnagNotifier.instance.notify(e, s, severity: ErrorSeverity.error);
      return null;
    }
  }
}
