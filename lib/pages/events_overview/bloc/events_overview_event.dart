part of 'events_overview_bloc.dart';

abstract class EventsOverviewEvent extends Equatable {
  const EventsOverviewEvent();
  @override
  List<Object> get props => [];
}

class TabberNavEvent extends EventsOverviewEvent {
  final int index;
  final String title;

  const TabberNavEvent({this.title, this.index = 0});
}

class LoadEventDetailEvent extends EventsOverviewEvent {
  final String id;

  const LoadEventDetailEvent(this.id);
}
