import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ticketapp/UI/event_overview/event_overview_bottom_info.dart';
import 'package:ticketapp/UI/event_overview/event_overview_navbar.dart';
import 'package:ticketapp/UI/event_overview/tabs/all_events.dart';
import 'package:ticketapp/UI/event_overview/tabs/for_me.dart';
import 'package:ticketapp/UI/event_overview/tabs/this_week.dart';
import 'package:ticketapp/UI/event_overview/tabs/this_weekend.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/pages/events_overview/bloc/events_overview_bloc.dart';
import 'package:ticketapp/pages/events_overview/featured_events/featured_events.dart';

class EventOverviewHome extends StatefulWidget {
  final List<Event> events;
  final EventsOverviewBloc bloc;

  const EventOverviewHome({Key key, this.events, this.bloc}) : super(key: key);

  @override
  _EventOverviewHomeState createState() => _EventOverviewHomeState();
}

class _EventOverviewHomeState extends State<EventOverviewHome> {
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                _eventOverview(screenSize).paddingBottom(16),
                _buildBody(context, screenSize).paddingBottom(16),
                EventOverviewFooter(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, Size screenSize) {
    return BlocBuilder<EventsOverviewBloc, EventsOverviewState>(
      cubit: widget.bloc,
      builder: (context, state) {
        if (state is AllEventsState) {
          return AllEvents(
            events: state.allEvents,
            headline: AutoSizeText.rich(
              TextSpan(
                  text: 'Events in',
                  style: Theme.of(context).textTheme.headline4.copyWith(fontWeight: FontWeight.w500),
                  children: [
                    TextSpan(
                      text: ' Perth',
                      style: Theme.of(context)
                          .textTheme
                          .headline4
                          .copyWith(color: MyTheme.appolloOrange, fontWeight: FontWeight.w500),
                    ),
                  ]),
            ),
          );
        } else if (state is FreeEventsState) {
          return AllEvents(
              events: state.freeEvents,
              headline: AutoSizeText.rich(
                TextSpan(
                    text: 'Free events in',
                    style: Theme.of(context).textTheme.headline4.copyWith(fontWeight: FontWeight.w500),
                    children: [
                      TextSpan(
                        text: ' Perth',
                        style: Theme.of(context)
                            .textTheme
                            .headline4
                            .copyWith(color: MyTheme.appolloOrange, fontWeight: FontWeight.w500),
                      ),
                    ]),
              ));
        } else if (state is ForMeEventsState) {
          return EventsForMe(scrollController: scrollController);
        } else if (state is TodayEventsState) {
          return AllEvents(
              events: state.todayEvents,
              headline: AutoSizeText.rich(
                TextSpan(
                    text: 'Events in',
                    style: Theme.of(context).textTheme.headline4.copyWith(fontWeight: FontWeight.w500),
                    children: [
                      TextSpan(
                        text: ' Perth',
                        style: Theme.of(context)
                            .textTheme
                            .headline4
                            .copyWith(color: MyTheme.appolloOrange, fontWeight: FontWeight.w500),
                      ),
                      TextSpan(
                        text: ' Today',
                      ),
                    ]),
              ));
        } else if (state is ThisWeekEventsState) {
          return ThisWeek(events: state.thisWeekEvents, scrollController: scrollController);
        } else if (state is ThisWeekendEventsState) {
          return ThisWeekend(events: state.weekendEvents, scrollController: scrollController);
        }
        /*else if (state is UpcomingEventsState) {
          return UpcomingEvents(events: state.upcomingEvents);
        }*/
        return SizedBox(
          height: 300,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget _eventOverview(Size screenSize) => Container(
        color: MyTheme.appolloBackgroundColor2,
        width: screenSize.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FeaturedEvents(),
            EventOverviewNavigationBar(bloc: widget.bloc),
          ],
        ),
      );
}

// ignore: must_be_immutable
class Menu extends Equatable {
  final int id;
  final String title;
  final String subtitle;
  final String fullDate;
  final String svgIcon;
  bool isTap;

  Menu(this.title, this.isTap, {this.id, this.subtitle, this.fullDate, this.svgIcon});

  @override
  List<Object> get props => [title];
}
