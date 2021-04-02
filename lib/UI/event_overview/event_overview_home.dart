import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ticketapp/UI/event_overview/event_overview_bottom_info.dart';
import 'package:ticketapp/UI/event_overview/event_overview_navbar.dart';
import 'package:ticketapp/UI/event_overview/featured_events.dart';
import 'package:ticketapp/UI/event_overview/tabs/all_events.dart';
import 'package:ticketapp/UI/event_overview/tabs/for_me.dart';
import 'package:ticketapp/UI/event_overview/tabs/free_events.dart';
import 'package:ticketapp/UI/event_overview/tabs/this_week.dart';
import 'package:ticketapp/UI/event_overview/tabs/this_weekend.dart';
import 'package:ticketapp/UI/event_overview/tabs/today_events.dart';
import 'package:ticketapp/UI/event_overview/tabs/upcoming_event.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/pages/events_overview/bloc/events_overview_bloc.dart';

class EventOverviewHome extends StatefulWidget {
  final List<Event> events;
  final EventsOverviewBloc bloc;

  const EventOverviewHome({
    Key key,
    this.events,
    this.bloc,
  }) : super(key: key);

  @override
  _EventOverviewHomeState createState() => _EventOverviewHomeState();
}

class _EventOverviewHomeState extends State<EventOverviewHome> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            controller: widget.bloc.scrollController,
            child: Container(
              child: Column(
                children: [
                  _eventOverview(screenSize).paddingBottom(16),
                  _buildBody(screenSize).paddingBottom(16),
                  EventOverviewFooter(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(screenSize) {
    return BlocBuilder<EventsOverviewBloc, EventsOverviewState>(
      cubit: widget.bloc,
      builder: (context, state) {
        print(state);
        if (state is AllEventsState) {
          return AllEvents(events: state.allEvents, upcomingEvents: state.upcomingEvents);
        } else if (state is FreeEventsState) {
          return FreeEvents(events: state.freeEvents);
        } else if (state is ForMeEventsState) {
          return EventsForMe();
        } else if (state is TodayEventsState) {
          return TodayEvents(events: state.todayEvents);
        } else if (state is ThisWeekEventsState) {
          return ThisWeek(events: state.thisWeekEvents, scrollController: widget.bloc.scrollController);
        } else if (state is ThisWeekendEventsState) {
          return ThisWeekend(events: state.weekendEvents, scrollController: widget.bloc.scrollController);
        } else if (state is UpcomingEventsState) {
          return UpcomingEvents(events: state.upcomingEvents);
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget _eventOverview(Size screenSize) => Container(
        color: MyTheme.appolloBlack,
        width: screenSize.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [FeaturedEvents(), EventOverviewNavigationBar(bloc: widget.bloc)],
        ),
      );
}

class Menu {
  String title;
  String subtitle;
  String fullDate;
  double pixel;

  bool isTap;
  Menu(this.title, this.isTap, {this.subtitle, this.fullDate, this.pixel});
}
