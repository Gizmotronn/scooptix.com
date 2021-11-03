part of 'bookings_bloc.dart';

abstract class BookingsState extends Equatable {
  const BookingsState();

  @override
  List<Object> get props => [];
}

class StateLoading extends BookingsState {}

class StateNoBookings extends BookingsState {}

class StateBookings extends BookingsState {
  final List<Booking> bookings;

  const StateBookings(this.bookings);
}
