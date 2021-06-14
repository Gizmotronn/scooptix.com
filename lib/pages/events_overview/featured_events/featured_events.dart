import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/pages/events_overview/featured_events/featured_events_desktop.dart';
import 'package:ticketapp/pages/events_overview/featured_events/featured_events_mobile.dart';
import 'package:ticketapp/repositories/events_repository.dart';

class FeaturedEvents extends StatefulWidget {
  @override
  _FeaturedEventsState createState() => _FeaturedEventsState();
}

class _FeaturedEventsState extends State<FeaturedEvents> {
  List<Event> events = [];

  @override
  void initState() {
    super.initState();

    events.addAll(EventsRepository.instance.upcomingPublicEvents);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return ResponsiveBuilder(
      builder: (context, size) {
        if (size.isDesktop || size.isTablet) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: kToolbarHeight + 20),
                  Container(width: MyTheme.maxWidth, child: FeaturedEventsDesktop(events: events)),
                ],
              )
            ],
          );
        } else {
          return FeaturedEventsMobile(events: events);
        }
      },
    );
  }
}
