import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:ticketapp/UI/event_overview/events.dart';
import 'package:ticketapp/UI/widgets/buttons/apollo_button.dart';
import 'package:ticketapp/UI/widgets/cards/white_card.dart';
import 'package:ticketapp/model/event.dart';

import '../../theme.dart';

class UpcomingEvents extends StatelessWidget {
  final List<Event> events;
  const UpcomingEvents({Key key, this.events}) : super(key: key);

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
                _eventTags(context,
                    tag: 'Upcoming Event in',
                    hightLightText: 'Perth',
                    count: '${events.length} Events'),
                AppolloEvents(events: events),
              ],
            ),
          ).paddingBottom(16),
          HoverAppolloButton(
            title: 'See More Events',
            color: MyTheme.appolloGreen,
            hoverColor: MyTheme.appolloGreen,
            fill: false,
          ),
        ],
      ),
    );
  }

  Widget _eventTags(context,
          {String tag, String count, String hightLightText}) =>
      Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AutoSizeText(tag,
                        style: Theme.of(context)
                            .textTheme
                            .headline3
                            .copyWith(color: MyTheme.appolloGrey))
                    .paddingRight(4),
                AutoSizeText(hightLightText,
                    style: Theme.of(context)
                        .textTheme
                        .headline3
                        .copyWith(color: MyTheme.appolloPurple)),
              ],
            ),
            AutoSizeText(count ?? '',
                style: Theme.of(context)
                    .textTheme
                    .headline3
                    .copyWith(color: MyTheme.appolloLightGrey)),
          ],
        ),
      ).paddingHorizontal(16).paddingTop(16);
}
