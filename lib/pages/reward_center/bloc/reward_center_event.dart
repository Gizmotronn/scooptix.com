part of 'reward_center_bloc.dart';

abstract class RewardCenterEvent extends Equatable {
  const RewardCenterEvent();

  @override
  List<Object> get props => [];
}

class EventLoadRewardCenter extends RewardCenterEvent {}
