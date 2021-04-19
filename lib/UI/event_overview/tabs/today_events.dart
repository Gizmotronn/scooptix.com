import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:ticketapp/UI/event_overview/events.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/cards/no_events.dart';
import 'package:ticketapp/UI/widgets/cards/appollo_bg_card.dart';
import 'package:ticketapp/model/event.dart';

class TodayEvents extends StatelessWidget {
  final List<Event> events;

  const TodayEvents({Key key, this.events}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    if (events.isEmpty) {
      return NoEvents();
    }
    return Container(
      width: screenSize.width * 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppolloBackgroundCard(
            child: Column(
              children: [
                _eventTags(context),
                AppolloEvents(events: events),
              ],
            ),
          ),
          const SizedBox(height: kToolbarHeight),
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
                  style: Theme.of(context).textTheme.headline3.copyWith(color: MyTheme.appolloWhite),
                  children: [
                    TextSpan(
                      text: ' Perth',
                      style: Theme.of(context).textTheme.headline3.copyWith(color: MyTheme.appolloOrange),
                    ),
                    TextSpan(
                      text: ' Today',
                    ),
                  ]),
            ),
            AutoSizeText("${events.length.toString() ?? ''} Events",
                style: Theme.of(context).textTheme.headline3.copyWith(color: MyTheme.appolloWhite)),
          ],
        ),
      ).paddingHorizontal(16).paddingTop(16);
}
