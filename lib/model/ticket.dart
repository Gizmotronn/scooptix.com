import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/model/ticket_release.dart';

class Ticket {
  Ticket();
  String? docId;
  Event? event;
  DateTime? dateIssued;
  TicketRelease? release;
  bool wasUsed = false;

  factory Ticket.fromMap(
      {required String id, Event? event, TicketRelease? release, required Map<String, dynamic> data}) {
    Ticket ticket = Ticket();
    ticket.docId = id;
    ticket.event = event;
    ticket.release = release;
    if (data.containsKey("requesttime")) {
      ticket.dateIssued = DateTime.fromMillisecondsSinceEpoch(data["requesttime"].millisecondsSinceEpoch);
    }
    if (data.containsKey("response")) {
      ticket.wasUsed = data["response"] == "granted" ? true : false;
    }
    return ticket;
  }
}
