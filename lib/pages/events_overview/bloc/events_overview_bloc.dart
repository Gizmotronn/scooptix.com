import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/model/organizer.dart';
import 'package:ticketapp/model/ticket_release.dart';
import 'package:ticketapp/repositories/events_repository.dart';
import 'package:ticketapp/repositories/user_repository.dart';
import '../../../repositories/ticket_repository.dart';

part 'events_overview_event.dart';
part 'events_overview_state.dart';

class EventsOverviewBloc extends Bloc<EventsOverviewEvent, EventsOverviewState> {
  Event? selectedEvent;

  EventsOverviewBloc() : super(LoadingEventsState());

  @override
  Stream<EventsOverviewState> mapEventToState(EventsOverviewEvent event) async* {
    if (event is TabberNavEvent) {
      yield* _handleSelectedTabEvent(event);
    } else if (event is LoadEventDetailEvent) {
      yield* _handleLoadEventDetail(event);
    }
  }

  Stream<EventsOverviewState> _handleSelectedTabEvent(TabberNavEvent event) async* {
    if (event.index == 0) {
      yield LoadingEventsState();
      final allEvents = EventsRepository.instance.upcomingPublicEvents;

      yield AllEventsState(allEvents);
    } else if (event.index == 1) {
      yield LoadingEventsState();
      List<Event> events = [];

      EventsRepository.instance.upcomingPublicEvents.forEach((event) {
        List<TicketRelease> release = event.getAllReleases();
        release.forEach((r) {
          if (r.price == 0) {
            events.add(event);
          }
        });
      });

      yield FreeEventsState(events);
    } else if (event.index == 2) {
      yield LoadingEventsState();

      yield ForMeEventsState();
    } else if (event.index == 3) {
      yield LoadingEventsState();
      final events = EventsRepository.instance.upcomingPublicEvents;
      final todayEvent = events
          .where((event) => event.date.day == DateTime.now().day && event.date.month == DateTime.now().month)
          .toList();

      yield TodayEventsState(todayEvent);
    } else if (event.index == 4) {
      yield LoadingEventsState();
      final events = EventsRepository.instance.upcomingPublicEvents;
      final thisWeekEndEvents =
          events.where((event) => event.date.isBefore(DateTime.now().add(Duration(days: 7)))).toList();

      yield ThisWeekendEventsState(thisWeekEndEvents);
    } else if (event.index == 5) {
      yield LoadingEventsState();
      final events = EventsRepository.instance.upcomingPublicEvents;
      final thisWeekEvent =
          events.where((event) => event.date.isBefore(DateTime.now().add(Duration(days: 7)))).toList();

      yield ThisWeekEventsState(thisWeekEvent);
    } else if (event.index == 6) {
      yield LoadingEventsState();

      List<Event> events = EventsRepository.instance.upcomingPublicEvents;
      yield UpcomingEventsState(events);
    }
  }

  Stream<EventsOverviewState> _handleLoadEventDetail(LoadEventDetailEvent e) async* {
    yield LoadingEventsState();
    try {
      final event = await EventsRepository.instance.loadEventById(e.id);
      final organizer = await UserRepository.instance.loadOrganizer(event!.organizer!);
      TicketRepository.instance.incrementLinkOpenedCounter(event);
      yield EventDetailState(event, organizer);
    } catch (e) {
      yield ErrorEventDetailState('404: Page Not Found');
    }
  }
}
