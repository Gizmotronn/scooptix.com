import 'package:webapp/model/ticket_release.dart';

class ReleaseManager {
  String docId;
  String name;
  DateTime entryStart;
  DateTime entryEnd;
  int index;
  List<String> releaseIds = [];
  List<TicketRelease> releases = [];
  List<TicketRelease> activeReleases = [];
  bool absorbFees;
  bool autoRelease;

  ReleaseManager._();

  TicketRelease getActiveRelease() {
    for (int i = 0; i < releaseIds.length; i++) {
      TicketRelease release = releases.firstWhere((tr) => tr.docId == releaseIds[i]);
      if (release.releaseStart.isBefore(DateTime.now()) && release.releaseEnd.isAfter(DateTime.now()) && release.maxTickets > release.ticketsBought) {
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
    } catch (e) {
      print(e);
    }
    return rm;
  }
}
