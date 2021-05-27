part of 'bookings_bloc.dart';

abstract class BookingsEvent extends Equatable {
  const BookingsEvent();

  @override
  List<Object> get props => [];
}

class EventLoadBookingData extends BookingsEvent {
  final Event event;

  const EventLoadBookingData(this.event);
}
