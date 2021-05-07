import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:ticketapp/UI/event_overview/events.dart';
import 'package:ticketapp/UI/widgets/cards/no_events.dart';
import 'package:ticketapp/UI/widgets/cards/appollo_bg_card.dart';
import 'package:ticketapp/model/event.dart';

import '../../theme.dart';

class UpcomingEvents extends StatelessWidget {
  final List<Event> events;
  const UpcomingEvents({Key key, this.events}) : super(key: key);

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
                _eventTags(context,
                    tag: 'Upcoming Events in', hightLightText: 'Perth', count: '${events.length} Events'),
                AppolloEvents(events: events),
              ],
            ),
          ).paddingBottom(16),
          // TODO:
          /*HoverAppolloButton(
            title: 'See More Events',
            color: MyTheme.appolloGreen,
            hoverColor: MyTheme.appolloGreen,
            fill: false,
          ),*/
        ],
      ),
    );
  }

  Widget _eventTags(context, {String tag, String count, String hightLightText}) => Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AutoSizeText(tag, style: MyTheme.lightTextTheme.headline4.copyWith(fontWeight: FontWeight.w500))
                    .paddingRight(4),
                AutoSizeText(hightLightText,
                    style: MyTheme.lightTextTheme.headline4
                        .copyWith(color: MyTheme.appolloOrange, fontWeight: FontWeight.w500)),
              ],
            ),
            AutoSizeText(count ?? '', style: MyTheme.lightTextTheme.headline4.copyWith(fontWeight: FontWeight.w500)),
          ],
        ),
      ).paddingHorizontal(16).paddingTop(16);
}
