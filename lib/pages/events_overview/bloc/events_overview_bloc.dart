import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'events_overview_event.dart';
part 'events_overview_state.dart';

class EventsOverviewBloc
    extends Bloc<EventsOverviewEvent, EventsOverviewState> {
  EventsOverviewBloc() : super(EventsOverviewInitial());

  @override
  Stream<EventsOverviewState> mapEventToState(
    EventsOverviewEvent event,
  ) async* {
    // TODO: implement mapEventToState
  }
}
