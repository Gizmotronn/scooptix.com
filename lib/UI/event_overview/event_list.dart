import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ticketapp/UI/event_details/event_card.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/model/link_type/overview.dart';
import 'package:ticketapp/pages/authentication/authentication_page.dart';

class AppolloEvents extends StatelessWidget {
  final List<Event> events;

  const AppolloEvents({Key key, this.events}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: List.generate(
          events.length,
          (index) => EventCard(
                eventTitle: events[index].name,
                eventAddress: events[index].address,
                eventTime:
                    "${DateFormat().add_Hm().format(events[index].date)} - ${DateFormat().add_Hm().format(events[index].endTime)}",
                eventImageUrl: events[index].coverImageURL,
                onTapGetEventTicket: () {
                  final linkType = OverviewLinkType(events[index]);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AuthenticationPage(linkType)));
                },
                onTapViewEvent: () {},
              )),
    );
  }
}
