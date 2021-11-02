part of 'birthday_list_bloc.dart';

abstract class BirthdayListEvent extends Equatable {
  const BirthdayListEvent();

  @override
  List<Object> get props => [];
}

class EventLoadBookingData extends BirthdayListEvent {
  final Event event;

  const EventLoadBookingData(this.event);
}

class EventLoadExistingList extends BirthdayListEvent {
  final Event event;

  const EventLoadExistingList(this.event);
}

class EventCreateList extends BirthdayListEvent {
  final Event event;
  final int numGuests;
  final BookingData booking;

  const EventCreateList(this.event, this.numGuests, this.booking);
}
