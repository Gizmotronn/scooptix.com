import 'package:flutter/material.dart';
import 'package:ticketapp/UI/widgets/cards/event_card.dart';
import 'package:ticketapp/model/event.dart';
import '../theme.dart';

class AppolloEvents extends StatelessWidget {
  const AppolloEvents({
    Key key,
    @required this.events,
  }) : super(key: key);

  final List<Event> events;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 0,
      runSpacing: 0,
      children: List.generate(events.length, (index) {
        return EventCard(
          event: events[index],
        );
      }),
    ).paddingAll(6);
  }
}
