import 'package:flutter/material.dart';
import 'package:ticketapp/UI/widgets/backgrounds/events_details_background.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/model/organizer.dart';
import 'package:ticketapp/pages/events_overview/bloc/events_overview_bloc.dart';

import 'mobile/event_details.dart';

class EventDetailsMobilePage extends StatefulWidget {
  final Event event;
  final Organizer organizer;
  final ScrollController scrollController;
  final EventsOverviewBloc bloc;

  const EventDetailsMobilePage(
      {Key? key, required this.bloc, required this.event, required this.organizer, required this.scrollController})
      : super(key: key);

  @override
  _EventDetailsMobilePageState createState() => _EventDetailsMobilePageState();
}

class _EventDetailsMobilePageState extends State<EventDetailsMobilePage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Needs an extra pop, otherwise only the bottom sheet is hidden
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        body: Stack(
          children: [
            EventDetailBackground(coverImageURL: widget.event.coverImageURL),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Align(
                alignment: Alignment.topCenter,
                child: EventDataMobile(
                  event: widget.event,
                  organizer: widget.organizer,
                  scrollController: widget.scrollController,
                  bloc: widget.bloc,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
