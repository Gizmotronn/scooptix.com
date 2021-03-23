import 'package:flutter/material.dart';
import 'package:ticketapp/UI/event_overview/event_overview_home.dart';
import 'package:ticketapp/UI/event_overview/event_top_nav.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/model/event.dart';

class EventOverviewPage extends StatelessWidget {
  final List<Event> events;
  const EventOverviewPage({Key key, this.events}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: MyTheme.appolloWhite,
      body: Container(
        color: MyTheme.appolloPurple.withAlpha(20),
        width: screenSize.width,
        height: screenSize.height,
        child: Stack(
          children: [
            EventOverviewHome(events: events),

            /// TODO More Events page with fliters and map
            // MoreEventsFliterMapPage(events: events),
            EventOverviewAppbar(),
          ],
        ),
      ),
    );
  }
}
