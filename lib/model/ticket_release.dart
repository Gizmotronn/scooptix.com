import 'package:ticketapp/services/bugsnag_wrapper.dart';

class TicketRelease {
  String docId = "";
  String name = "";
  String description = "";
  String ticketName = "";
  DateTime entryStart;
  DateTime entryEnd;
  DateTime releaseStart;
  DateTime releaseEnd;
  int maxTickets = 0;
  int ticketsBought = 0;
  int price;

  int ticketsLeft() {
    return maxTickets - ticketsBought;
  }

  TicketRelease._();

  factory TicketRelease.fromMap(String id, Map<String, dynamic> data, String releaseManagerName) {
    TicketRelease release = TicketRelease._();

    try {
      release.docId = id;
      if (data.containsKey("name")) {
        release.name = data["name"];
      }
      if (data.containsKey("description")) {
        release.description = data["description"];
      }
      if (data.containsKey("entry_start")) {
        release.entryStart = DateTime.fromMillisecondsSinceEpoch(data["entry_start"].millisecondsSinceEpoch);
      }
      if (data.containsKey("entry_end")) {
        release.entryEnd = DateTime.fromMillisecondsSinceEpoch(data["entry_end"].millisecondsSinceEpoch);
      }
      if (data.containsKey("release_start")) {
        release.releaseStart = DateTime.fromMillisecondsSinceEpoch(data["release_start"].millisecondsSinceEpoch);
      }
      if (data.containsKey("release_end")) {
        release.releaseEnd = DateTime.fromMillisecondsSinceEpoch(data["release_end"].millisecondsSinceEpoch);
      }
      if (data.containsKey("max_tickets")) {
        release.maxTickets = data["max_tickets"];
      }
      if (data.containsKey("tickets_bought")) {
        release.ticketsBought = data["tickets_bought"];
      }
      if (data.containsKey("price")) {
        release.price = data["price"];
      }
      release.ticketName = releaseManagerName;
    } catch (e, s) {
      print(e);
      BugsnagNotifier.instance.notify("Error loading ticket release \n $e", s, severity: ErrorSeverity.error);
    }

    return release;
  }
}
