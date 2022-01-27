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
import 'package:ticketapp/services/facebook_pixel.dart';
import '../../../repositories/ticket_repository.dart';

part 'events_overview_event.dart';
part 'events_overview_state.dart';

class EventsOverviewBloc extends Bloc<EventsOverviewEvent, EventsOverviewState> {
  Event? selectedEvent;

  EventsOverviewBloc() : super(LoadingEventsState()) {
    on<TabberNavEvent>(_handleSelectedTabEvent);
    on<LoadEventDetailEvent>(_handleLoadEventDetail);
  }

  _handleSelectedTabEvent(TabberNavEvent event, emit) async {
    if (event.index == 0) {
      emit(LoadingEventsState());
      final allEvents = EventsRepository.instance.upcomingPublicEvents;

      emit(AllEventsState(allEvents));
    } else if (event.index == 1) {
        emit(LoadingEventsState());
      List<Event> events = [];

      EventsRepository.instance.upcomingPublicEvents.forEach((event) {
        List<TicketRelease> release = event.getAllReleases();
        release.forEach((r) {
          if (r.price == 0) {
            events.add(event);
          }
        });
      });

      emit(FreeEventsState(events));
    } else if (event.index == 2) {
      emit(LoadingEventsState());

      emit(ForMeEventsState());
    } else if (event.index == 3) {
      emit(LoadingEventsState());
      final events = EventsRepository.instance.upcomingPublicEvents;
      final todayEvent = events
          .where((event) => event.date.day == DateTime.now().day && event.date.month == DateTime.now().month)
          .toList();

      emit(TodayEventsState(todayEvent));
    } else if (event.index == 4) {
      emit(LoadingEventsState());
      final events = EventsRepository.instance.upcomingPublicEvents;
      final thisWeekEndEvents =
          events.where((event) => event.date.isBefore(DateTime.now().add(Duration(days: 7)))).toList();

      emit(ThisWeekendEventsState(thisWeekEndEvents));
    } else if (event.index == 5) {
      emit(LoadingEventsState());
      final events = EventsRepository.instance.upcomingPublicEvents;
      final thisWeekEvent =
          events.where((event) => event.date.isBefore(DateTime.now().add(Duration(days: 7)))).toList();

      emit(ThisWeekEventsState(thisWeekEvent));
    } else if (event.index == 6) {
      emit(LoadingEventsState());

      List<Event> events = EventsRepository.instance.upcomingPublicEvents;
      emit(UpcomingEventsState(events));
    }
  }

  _handleLoadEventDetail(LoadEventDetailEvent e, emit) async {
    emit(LoadingEventsState());
    try {
      final event = await EventsRepository.instance.loadEventById(e.id);
      final organizer = await UserRepository.instance.loadOrganizer(event!.organizer!);
      TicketRepository.instance.incrementLinkOpenedCounter(event);
      if (event.pixelId != null) {
        FBPixelService.instance.sendPageViewEvent(event.pixelId!);
      }

      emit(EventDetailState(event, organizer));
    } catch (e) {
        emit(ErrorEventDetailState('404: Page Not Found'));
    }
  }
}
