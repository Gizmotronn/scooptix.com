part of 'reward_center_bloc.dart';

abstract class RewardCenterState extends Equatable {
  const RewardCenterState();
  @override
  List<Object> get props => [];
}

class StateLoading extends RewardCenterState {}

class StateRewards extends RewardCenterState {
  final List<PreSaleRegistration> preSales;

  const StateRewards(this.preSales);
}
