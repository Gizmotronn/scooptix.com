import 'package:webapp/model/ticket_release.dart';
import 'package:webapp/services/bugsnag_wrapper.dart';

class ReleaseManager {
  String docId;
  String name;
  DateTime entryStart;
  DateTime entryEnd;
  int index;
  List<String> releaseIds = [];
  List<TicketRelease> releases = [];

  ReleaseManager._();

  TicketRelease getActiveRelease() {
    for (int i = 0; i < releaseIds.length; i++) {
      TicketRelease release = releases.firstWhere((tr) => tr.docId == releaseIds[i]);
      if (release.maxTickets > release.ticketsBought) {
        return release;
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
      if (data.containsKey("releases")) {
        rm.releaseIds = data["releases"].cast<String>().toList();
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
