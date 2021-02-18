import 'package:webapp/model/ticket_release.dart';
import 'package:webapp/services/bugsnag_wrapper.dart';

class ReleaseManager {
  String docId;
  String name;
  String description;
  DateTime entryStart;
  DateTime entryEnd;
  int index;
  List<TicketRelease> releases = [];
  bool absorbFees = false;
  bool autoRelease = false;

  ReleaseManager._();

  TicketRelease getActiveRelease() {
    // Sort by earliest release start first
    releases.sort((a, b) => a.releaseStart.isBefore(b.releaseStart) ? -1 : 1);
    for (int i = 0; i < releases.length; i++) {
      // If autorelease is true, we can ignore the release start time if the first release is already sold out
      // This is why we sort the releases first
      if ((releases[i].releaseStart.isBefore(DateTime.now()) || (i != 0 && autoRelease)) &&
          releases[i].releaseEnd.isAfter(DateTime.now()) &&
          releases[i].maxTickets > releases[i].ticketsBought) {
        return releases[i];
      }
    }
    return null;
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
      if (data.containsKey("entry_start")) {
        rm.entryStart = DateTime.fromMillisecondsSinceEpoch(data["entry_start"].millisecondsSinceEpoch);
      }
      if (data.containsKey("entry_end")) {
        rm.entryEnd = DateTime.fromMillisecondsSinceEpoch(data["entry_end"].millisecondsSinceEpoch);
      }
    } catch (e, s) {
      print(e);
      BugsnagNotifier.instance.notify(e, s, severity: ErrorSeverity.error);
    }
    return rm;
  }
}
