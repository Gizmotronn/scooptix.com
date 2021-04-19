import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ticketapp/repositories/events_repository.dart';

import '../../../UI/theme.dart';
import '../../../UI/widgets/cards/event_card.dart';
import '../../../model/event.dart';

class SimilarOtherEvents extends StatefulWidget {
  final Event event;

  const SimilarOtherEvents({Key key, this.event}) : super(key: key);
  @override
  _SimilarOtherEventsState createState() => _SimilarOtherEventsState();
}

class _SimilarOtherEventsState extends State<SimilarOtherEvents> {
  List<Event> _similarEvents = [];
  List<Event> _otherEventsByThisOrganizer = [];

  @override
  void initState() {
    final events = EventsRepository.instance.events;
    _similarEvents = events
        .where((event) => event.name.contains(widget.event.name) || event.tags.contains(widget.event.tags))
        .toList();
    _otherEventsByThisOrganizer = events.where((event) => event.organizer == widget.event.organizer).toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _otherEventsByThisOrganizer.isEmpty ? SizedBox() : _otherEventByThisOrganizer(context),
        _similarEvents.isEmpty ? SizedBox() : _similarEvent(context).paddingBottom(32),
      ],
    );
  }

  Widget _similarEvent(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoSizeText.rich(
            TextSpan(
              text: 'Similar Events    ',
              children: [
                TextSpan(
                  text: 'View All',
                  style: Theme.of(context).textTheme.subtitle1.copyWith(decoration: TextDecoration.underline),
                )
              ],
            ),
            style: Theme.of(context).textTheme.headline3.copyWith(color: MyTheme.appolloOrange),
          ).paddingBottom(32),
          SizedBox(
            height: 320,
            child: ListView(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              physics: NeverScrollableScrollPhysics(),
              children: List.generate(
                _similarEvents.length,
                (index) => EventCard(event: _similarEvents[index]),
              ),
            ),
          ),
        ],
      );

  Widget _otherEventByThisOrganizer(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoSizeText.rich(
            TextSpan(
              text: 'Other Event By This Organizer    ',
              children: [
                TextSpan(
                  text: 'View All',
                  style: Theme.of(context).textTheme.subtitle1.copyWith(decoration: TextDecoration.underline),
                )
              ],
            ),
            style: Theme.of(context).textTheme.headline3.copyWith(color: MyTheme.appolloOrange),
          ).paddingBottom(32),
          SizedBox(
            height: 320,
            child: ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              children: List.generate(
                _otherEventsByThisOrganizer.length,
                (index) => EventCard(event: _otherEventsByThisOrganizer[index]),
              ),
            ),
          ),
        ],
      );
}
