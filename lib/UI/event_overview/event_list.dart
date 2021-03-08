import 'package:flutter/material.dart';
import 'package:ticketapp/UI/event_overview/event_card.dart';
import 'package:ticketapp/model/event.dart';

class AppolloEvents extends StatelessWidget {
  final List<Event> events;

  const AppolloEvents({Key key, this.events}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: List.generate(
          events.length,
          (index) => EventCard(
                event: events[index],
              )),
    );
  }
}
