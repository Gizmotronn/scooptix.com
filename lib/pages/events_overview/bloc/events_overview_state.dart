part of 'events_overview_bloc.dart';

@immutable
abstract class EventsOverviewState extends Equatable {
  const EventsOverviewState();

  @override
  List<Object> get props => [];
}

class LoadingEventsState extends EventsOverviewState {
  const LoadingEventsState();
}

class AllEventsState extends EventsOverviewState {
  final List<Event> allEvents;
  final List<Event> upcomingEvents;

  const AllEventsState(this.allEvents, this.upcomingEvents);
}

class FreeEventsState extends EventsOverviewState {
  final List<Event> freeEvents;
  const FreeEventsState(this.freeEvents);
}

class ForMeEventsState extends EventsOverviewState {
  const ForMeEventsState();
}

class TodayEventsState extends EventsOverviewState {
  final List<Event> todayEvents;
  const TodayEventsState(this.todayEvents);
}

class ThisWeekendEventsState extends EventsOverviewState {
  final List<Event> weekendEvents;
  const ThisWeekendEventsState(this.weekendEvents);
}

class ThisWeekEventsState extends EventsOverviewState {
  final List<Event> thisWeekEvents;
  const ThisWeekEventsState(this.thisWeekEvents);
}

class UpcomingEventsState extends EventsOverviewState {
  final List<Event> upcomingEvents;
  const UpcomingEventsState(this.upcomingEvents);
}

class EventDetailState extends EventsOverviewState {
  final Event event;
  final Organizer organizer;
  const EventDetailState(this.event, this.organizer);
}

class ErrorEventDetailState extends EventsOverviewState {
  final String message;
  const ErrorEventDetailState(this.message);
}
