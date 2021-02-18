import 'dart:html';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:webapp/pages/authentication/landing_page.dart';
import 'package:webapp/pages/error_page.dart';
import 'package:webapp/repositories/events_repository.dart';
import 'package:webapp/services/bugsnag_wrapper.dart';

class EventSelectionPage extends StatefulWidget {
  const EventSelectionPage({Key key}) : super(key: key);

  @override
  _EventSelectionPageState createState() => _EventSelectionPageState();
}

class _EventSelectionPageState extends State<EventSelectionPage> {
  @override
  void initState() {
    Intl.defaultLocale = 'en_AU';
    initializeDateFormatting('en_AU', null);
    final uri = Uri.parse(window.location.href);
    String uuid = "2857e5e5-cfdc-45e3-a4ea-f48160abe949";
    if (uri.queryParameters.containsKey("id")) {
      uuid = uri.queryParameters["id"];
    }

    EventsRepository.instance.loadLinkType(uuid).then((value) {
      if (value == null) {
        String message = "Invalid link. Please make sure you have copied the entire link.";
        if (uuid != "") {
          message =
              "There is no event associated with the provided id $uuid. Please make sure you have copied the correct link";
        }
        BugsnagNotifier.instance.notify("Invalid UUID, provided UUID: $uuid", StackTrace.empty);

        Navigator.push(context, MaterialPageRoute(builder: (context) => ErrorPage(message)));
      } else
        Navigator.push(context, MaterialPageRoute(builder: (context) => AuthenticationPage(value)));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}
