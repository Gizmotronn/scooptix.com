import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/model/ticket_release.dart';
import 'package:ticketapp/repositories/events_repository.dart';

part 'events_overview_event.dart';
part 'events_overview_state.dart';

class EventsOverviewBloc
    extends Bloc<EventsOverviewEvent, EventsOverviewState> {
  Event selectedEvent;

  ScrollController _scrollcontroller = ScrollController();

  ScrollController get scrollController => _scrollcontroller;

  EventsOverviewBloc() : super(LoadingEventsState());
  @override
  Future<void> close() {
    _scrollcontroller.dispose();
    EventsRepository.instance.dispose();
    return super.close();
  }

  @override
  Stream<EventsOverviewState> mapEventToState(
      EventsOverviewEvent event) async* {
    if (event is TabberNavEvent) {
      yield* _handleSelectedTabEvent(event);
    }
  }

  Stream<EventsOverviewState> _handleSelectedTabEvent(
      TabberNavEvent event) async* {
    yield LoadingEventsState();
    if (event.index == 0) {
      List<Event> upcomingEvents =
          await EventsRepository.instance.loadUpcomingEvents();
      yield AllEventsState(EventsRepository.instance.events, upcomingEvents);
    } else if (event.index == 1) {
      List<Event> events = [];

      EventsRepository.instance.events.forEach((event) {
        List<TicketRelease> release = event.getAllReleases();

        release.forEach((r) {
          if (r.price == 0) {
            events.add(event);
          }
        });
      });
      yield LoadingEventsState();

      yield FreeEventsState(events);
    } else if (event.index == 2) {
      yield LoadingEventsState();

      yield ForMeEventsState();
    } else if (event.index == 3) {
      yield LoadingEventsState();
      yield TodayEventsState(EventsRepository.instance.events
          .where((event) => event.date.day == DateTime.now().day)
          .toList());
    } else if (event.index == 4) {
      yield LoadingEventsState();

      yield ThisWeekendEventsState(EventsRepository.instance.events
          .where((event) =>
              event.date.isBefore(DateTime.now().add(Duration(days: 7))))
          .toList());
    } else if (event.index == 5) {
      yield LoadingEventsState();

      yield ThisWeekEventsState(EventsRepository.instance.events
          .where((event) =>
              event.date.isBefore(DateTime.now().add(Duration(days: 14))))
          .toList());
    } else if (event.index == 6) {
      yield LoadingEventsState();

      List<Event> events = await EventsRepository.instance.loadUpcomingEvents();
      yield UpcomingEventsState(events);
    }
  }
}
