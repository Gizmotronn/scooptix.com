import 'package:flutter/material.dart';
import 'package:ticketapp/UI/widgets/cards/event_card.dart';
import 'package:ticketapp/model/event.dart';
import '../theme.dart';

class AppolloEvents extends StatelessWidget {
  final List<Event> events;

  const AppolloEvents({Key key, @required this.events}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: events.length < 2 ? Alignment.topLeft : Alignment.topCenter,
      child: Wrap(
        children: events.map((event) => EventCard(event: event)).toList(),
      ).paddingAll(6),
    );
  }
}
