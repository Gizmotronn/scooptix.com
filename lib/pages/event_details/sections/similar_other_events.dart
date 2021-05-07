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
        _otherEventsByThisOrganizer.isEmpty
            ? SizedBox()
            : _otherEventByThisOrganizer(context).paddingBottom(MyTheme.elementSpacing),
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
              /* children: [
                TextSpan(
                  text: 'View All',
                  style: Theme.of(context).textTheme.subtitle1.copyWith(decoration: TextDecoration.underline),
                )
              ],*/
            ),
            style: Theme.of(context)
                .textTheme
                .headline4
                .copyWith(color: MyTheme.appolloOrange, fontWeight: FontWeight.w500),
          ).paddingBottom(32),
          SizedBox(
            height: 320,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: _similarEvents.length > 3 ? 3 : _similarEvents.length,
              itemBuilder: (c, index) {
                return EventCard(
                  event: _similarEvents[index],
                  width: MyTheme.maxWidth / 3,
                );
              },
            ),
          ),
        ],
      );

  Widget _otherEventByThisOrganizer(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoSizeText.rich(
            TextSpan(
              text: 'Other Events By This Organizer    ',
              /* children: [
                TextSpan(
                  text: 'View All',
                  style: Theme.of(context).textTheme.subtitle1.copyWith(decoration: TextDecoration.underline),
                )
              ],*/
            ),
            style: Theme.of(context)
                .textTheme
                .headline4
                .copyWith(color: MyTheme.appolloGreen, fontWeight: FontWeight.w500),
          ).paddingBottom(32),
          SizedBox(
            height: 320,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (c, index) {
                return EventCard(event: _otherEventsByThisOrganizer[index], width: MyTheme.maxWidth / 3);
              },
              itemCount: _otherEventsByThisOrganizer.length > 3 ? 3 : _otherEventsByThisOrganizer.length,
            ),
          ),
        ],
      );
}
