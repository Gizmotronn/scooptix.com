import 'package:webapp/model/ticket_release.dart';
import 'package:webapp/services/bugsnag_wrapper.dart';

class ReleaseManager {
  String docId;
  String name;
  DateTime entryStart;
  DateTime entryEnd;
  int index;
  List<TicketRelease> releases = [];
  bool absorbFees;
  bool autoRelease;

  ReleaseManager._();

  TicketRelease getActiveRelease() {
    for (int i = 0; i < releases.length; i++) {
      if (releases[i].releaseStart.isBefore(DateTime.now()) && releases[i].releaseEnd.isAfter(DateTime.now()) && releases[i].maxTickets > releases[i].ticketsBought) {
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
      if (data.containsKey("index")) {
        rm.index = data["index"];
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
