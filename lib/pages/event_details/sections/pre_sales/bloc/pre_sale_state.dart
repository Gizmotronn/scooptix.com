part of 'pre_sale_bloc.dart';

abstract class PreSaleState extends Equatable {
  const PreSaleState();

  @override
  List<Object> get props => [];
}

class StateLoading extends PreSaleState {}

class StateNotLoggedIn extends PreSaleState {}

class StateNotRegistered extends PreSaleState {}

class StateRegistered extends PreSaleState {
  final PreSaleRegistration preSale;

  const StateRegistered(this.preSale);
}
