import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:ticketapp/UI/event_overview/tabs/upcoming_event.dart';
import 'package:ticketapp/UI/widgets/cards/white_card.dart';
import 'package:ticketapp/model/event.dart';

import '../../theme.dart';
import '../events.dart';

class AllEvents extends StatelessWidget {
  final List<Event> events;
  final List<Event> upcomingEvents;

  const AllEvents({Key key, this.events, this.upcomingEvents})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      width: screenSize.width * 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          WhiteCardWithNoElevation(
            child: Column(
              children: [
                _eventTags(context),
                AppolloEvents(events: events),
              ],
            ),
          ).paddingBottom(16),
          UpcomingEvents(events: upcomingEvents),
        ],
      ),
    );
  }

  Widget _eventTags(context) => Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutoSizeText.rich(
              TextSpan(
                  text: 'Events in',
                  style: Theme.of(context)
                      .textTheme
                      .headline3
                      .copyWith(color: MyTheme.appolloGrey),
                  children: [
                    TextSpan(
                      text: ' Perth',
                      style: Theme.of(context)
                          .textTheme
                          .headline3
                          .copyWith(color: MyTheme.appolloPurple),
                    ),
                    TextSpan(
                      text: ' This Week',
                    ),
                  ]),
            ),
            AutoSizeText(events.length.toString() ?? '',
                style: Theme.of(context)
                    .textTheme
                    .headline3
                    .copyWith(color: MyTheme.appolloLightGrey)),
          ],
        ),
      ).paddingHorizontal(16).paddingTop(16);
}
