part of 'bookings_bloc.dart';

abstract class BookingsState extends Equatable {
  const BookingsState();

  @override
  List<Object> get props => [];
}

class StateLoading extends BookingsState {}

class StateBookingData extends BookingsState {
  final BookingData booking;

  const StateBookingData(this.booking);
}

class StateNoBookingsAvailable extends BookingsState {}
