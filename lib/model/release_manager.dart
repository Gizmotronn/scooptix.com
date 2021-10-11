import 'package:ticketapp/model/ticket_release.dart';
import 'package:ticketapp/services/bugsnag_wrapper.dart';

class ReleaseManager {
  String? docId;
  String? name;
  String? description;
  DateTime? entryStart;
  DateTime? entryEnd;
  int? index;
  List<TicketRelease> releases = [];
  bool absorbFees = false;
  bool autoRelease = false;
  bool singleTicketRestriction = false;
  List<int> availablePerks = [];
  String? recurringUUID;

  /// Stores the link types this release is available for
  List<String>? availableFor;

  ReleaseManager._();

  bool isAvailableFor(String linkType) {
    if (availableFor == null || availableFor!.contains(linkType)) {
      return true;
    } else {
      return false;
    }
  }

  TicketRelease? getActiveRelease() {
    // Sort by earliest release start first
    releases.sort((a, b) => a.releaseStart!.compareTo(b.releaseStart!));
    for (int i = 0; i < releases.length; i++) {
      // Autorelease should only start after the first release has sold out
      if (autoRelease && releases[i].releaseStart!.isAfter(DateTime.now())) {
        return null;
      }

      // If autorelease is true, we can ignore the release start time if the first release is already sold out
      // This is why we sort the releases first
      if ((releases[i].releaseStart!.isBefore(DateTime.now()) || (i != 0 && autoRelease)) &&
          releases[i].releaseEnd!.isAfter(DateTime.now()) &&
          releases[i].maxTickets > releases[i].ticketsBought) {
        return releases[i];
      }
    }
    return null;
  }

  /// Returns the next release that will be active, which might not be active right now
  TicketRelease? getNextRelease() {
    // Sort by earliest release start first
    releases.sort((a, b) => a.releaseStart!.compareTo(b.releaseStart!));
    for (int i = 0; i < releases.length; i++) {
      // Autorelease should only start after the first release has sold out
      if (autoRelease && i == 0 && releases[i].releaseStart!.isAfter(DateTime.now())) {
        return releases[0];
      }

      // If autorelease is true, we can ignore the release start time if the first release is already sold out
      // This is why we sort the releases first
      if ((releases[i].releaseStart!.isBefore(DateTime.now()) || (i != 0 && autoRelease)) &&
          releases[i].releaseEnd!.isAfter(DateTime.now()) &&
          releases[i].maxTickets > releases[i].ticketsBought) {
        return releases[i];
      }
    }
    if (releases.any((element) => element.releaseEnd!.isAfter(DateTime.now()))) {
      return releases.firstWhere((element) => element.releaseEnd!.isAfter(DateTime.now()));
    }
    return null;
  }

  int? getFullPrice() {
    return releases.isEmpty ? 0 : releases.last.price;
  }

  bool isSoldOut() {
    return !releases.any((element) => element.maxTickets > element.ticketsBought);
  }

  factory ReleaseManager.fromMap(String id, Map<String, dynamic> data) {
    ReleaseManager rm = ReleaseManager._();

    try {
      rm.docId = id;
      if (data.containsKey("name")) {
        rm.name = data["name"];
      }
      if (data.containsKey("description")) {
        rm.description = data["description"];
      }
      if (data.containsKey("index")) {
        rm.index = data["index"];
      }
      if (data.containsKey("absorb_fees")) {
        rm.absorbFees = data["absorb_fees"];
      }
      if (data.containsKey("auto_release")) {
        rm.autoRelease = data["auto_release"];
      }
      if (data.containsKey("available_perks")) {
        rm.availablePerks = data["available_perks"].cast<int>().toList();
      }
      if (data.containsKey("entry_start")) {
        rm.entryStart = DateTime.fromMillisecondsSinceEpoch(data["entry_start"].millisecondsSinceEpoch);
      }
      if (data.containsKey("entry_end")) {
        rm.entryEnd = DateTime.fromMillisecondsSinceEpoch(data["entry_end"].millisecondsSinceEpoch);
      }
      if (data.containsKey("single_ticket_restriction")) {
        rm.singleTicketRestriction = data["single_ticket_restriction"];
      }
      if (data.containsKey("recurring_uuid")) {
        rm.recurringUUID = data["recurring_uuid"];
      }
      if (data.containsKey("available_for")) {
        rm.availableFor = [];
        data["available_for"].forEach((e) {
          rm.availableFor!.add(e);
        });
      }
    } catch (e, s) {
      BugsnagNotifier.instance.notify("Error loading release manager \n $e", s, severity: ErrorSeverity.error);
    }
    return rm;
  }
}
