import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:ticketapp/UI/event_details/event_card.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/apollo_button.dart';
import 'package:ticketapp/model/event.dart';

class EventOverviewPage extends StatefulWidget {
  final List<Event> events;
  const EventOverviewPage({Key key, this.events}) : super(key: key);

  @override
  _EventOverviewPageState createState() => _EventOverviewPageState();
}

class _EventOverviewPageState extends State<EventOverviewPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: EventCard(
                eventTitle: 'Humble End Of Exams',
                eventAddress: '90-Aberdeeen St.., Perth',
                eventTime: '4:00PM - 1:00AM',
                eventImageUrl: null,
                onTapGetEventTicket: () {},
                onTapViewEvent: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
