import 'dart:html';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/pages/authentication/authentication_page.dart';
import 'package:ticketapp/pages/error_page.dart';
import 'package:ticketapp/pages/events_overview/events_overview_page.dart';
import 'package:ticketapp/repositories/events_repository.dart';
import 'package:ticketapp/services/bugsnag_wrapper.dart';
import 'package:ticketapp/UI/theme.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key key}) : super(key: key);

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    Intl.defaultLocale = 'en_AU';
    initializeDateFormatting('en_AU', null);
    final uri = Uri.parse(window.location.href);
    String uuid = ""; // Use this for normal functionality
    // String uuid = "jAPHBX"; // Takes you to a test event

    if (uri.queryParameters.containsKey("id")) {
      uuid = uri.queryParameters["id"];
    }

    // If an event link was used, load this event and forward the user to the event details page.
    EventsRepository.instance.loadLinkType(uuid).then((value) {
      if (value == null) {
        String message =
            "Invalid link. Please make sure you have copied the entire link.";
        if (uuid != "") {
          message =
              "There is no event associated with the provided id $uuid. Please make sure you have copied the correct link";
        }
        preloadEventsAndNavigate();
        BugsnagNotifier.instance
            .notify("Invalid UUID, provided UUID: $uuid", StackTrace.empty);
      } else
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => AuthenticationPage(value)));
    });

    // Currently if no id is provided with the link, the above code shows an error message. Instead the event overview page should be shown.

    super.initState();
  }

  void preloadEventsAndNavigate() async {
    // final events = await EventsRepository.instance.loadUpcomingEvents();
    // print(events.length);
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => EventOverviewPage(events: [])));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          CircularProgressIndicator().paddingBottom(8),
        ],
      ),
    );
  }
}
