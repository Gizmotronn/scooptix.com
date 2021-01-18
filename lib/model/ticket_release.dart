import 'package:webapp/model/ticket_type.dart';
import 'package:webapp/services/bugsnag_wrapper.dart';

class TicketRelease {
  String docId = "";
  String name = "";
  String description = "";
  DateTime entryStart;
  DateTime entryEnd;
  int maxTickets = 0;
  int ticketsBought = 0;
  List<TicketType> ticketTypes = [];

  TicketRelease._();

  factory TicketRelease.fromMap(String id, Map<String, dynamic> data) {
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
      if (data.containsKey("max_tickets")) {
        release.maxTickets = data["max_tickets"];
      }
      if (data.containsKey("tickets_bought")) {
        release.ticketsBought = data["tickets_bought"];
      }
      if (data.containsKey("ticket_types")) {
        data["ticket_types"].forEach((key, value) {
          TicketType tt = TicketType()
            ..name = key
            ..ticketsBought = value["tickets_bought"]
            ..price = value["price"];
          release.ticketTypes.add(tt);
        });
      }
    } catch (e, s) {
      print(e);
      BugsnagNotifier.instance.notify(e, s, severity: ErrorSeverity.error);
    }

    return release;
  }
}
