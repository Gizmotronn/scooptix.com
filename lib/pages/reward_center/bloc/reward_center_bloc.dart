import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ticketapp/model/pre_sale/pre_sale_registration.dart';
import 'package:ticketapp/repositories/presale_repository.dart';
import 'package:ticketapp/repositories/user_repository.dart';

part 'reward_center_event.dart';
part 'reward_center_state.dart';

class RewardCenterBloc extends Bloc<RewardCenterEvent, RewardCenterState> {
  RewardCenterBloc() : super(StateLoading()) {
    on<EventLoadRewardCenter>(loadRewardCenterData);
  }

  loadRewardCenterData(data, emit) async {
    emit(StateLoading());
    List<PreSaleRegistration> preSales = await PreSaleRepository.instance
        .loadPreSaleRegistrations(UserRepository.instance.currentUser()!.firebaseUserID);
    emit(StateRewards(preSales));
  }
}
