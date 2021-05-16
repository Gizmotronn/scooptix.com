import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/pages/events_overview/event_card_desktop.dart';
import 'package:ticketapp/pages/events_overview/event_card_mobile.dart';
import '../theme.dart';

class AppolloEvents extends StatelessWidget {
  final List<Event> events;

  const AppolloEvents({Key key, @required this.events}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (c, size) {
        if (size.isDesktop || size.isTablet) {
          return Align(
            alignment: Alignment.topCenter,
            child: Wrap(
              children: events.map((event) => EventCardDesktop(event: event)).toList(),
            ).paddingAll(6),
          );
        } else {
          return Align(
            alignment: Alignment.topCenter,
            child: Column(
              children:
                  events.map((event) => EventCardMobile(event: event).paddingBottom(MyTheme.elementSpacing)).toList(),
            ).paddingHorizontal(MyTheme.elementSpacing / 2).paddingTop(MyTheme.elementSpacing),
          );
        }
      },
    );
  }
}
