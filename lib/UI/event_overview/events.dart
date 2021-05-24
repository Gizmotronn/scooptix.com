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
            child: GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: events.length,
              itemBuilder: (context, index) {
                return EventCardDesktop(
                    event: events[index],
                    width: MyTheme.maxWidth /
                        ((MyTheme.maxWidth / 250).floor() > 4 ? 4 : (MyTheme.maxWidth / 250).floor()));
              },
              gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 1,
                crossAxisCount: (MyTheme.maxWidth / 250).floor() > 4 ? 4 : (MyTheme.maxWidth / 250).floor(),
              ),
            ).paddingAll(6),
          );
        } else {
          return Align(
            alignment: Alignment.topCenter,
            child: ListView.builder(
              padding: EdgeInsets.only(top: MyTheme.elementSpacing),
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: events.length,
              itemBuilder: (context, index) =>
                  EventCardMobile(event: events[index]).paddingBottom(MyTheme.elementSpacing * 3),
            ).paddingHorizontal(MyTheme.elementSpacing / 2),
          );
        }
      },
    );
  }
}
