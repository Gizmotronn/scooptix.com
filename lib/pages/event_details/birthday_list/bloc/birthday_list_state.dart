part of 'birthday_list_bloc.dart';

abstract class BirthdayListState extends Equatable {
  const BirthdayListState();

  @override
  List<Object> get props => [];
}

class StateLoading extends BirthdayListState {}

class StateCreatingList extends BirthdayListState {}

class StateExistingList extends BirthdayListState {
  final BirthdayList birthdayList;

  const StateExistingList(this.birthdayList);
}

class StateNoList extends BirthdayListState {}

class StateTooFarAway extends BirthdayListState {}

class StateError extends BirthdayListState {
  final String message;

  const StateError(this.message);
}

class StateBookingData extends BirthdayListState {
  final BookingData booking;

  const StateBookingData(this.booking);
}

class StateNoBookingsAvailable extends BirthdayListState {}
