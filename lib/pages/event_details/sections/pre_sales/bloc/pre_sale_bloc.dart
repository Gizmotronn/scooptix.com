import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/model/pre_sale/pre_sale_registration.dart';
import 'package:ticketapp/repositories/presale_repository.dart';
import 'package:ticketapp/repositories/user_repository.dart';

part 'pre_sale_event.dart';
part 'pre_sale_state.dart';

class PreSaleBloc extends Bloc<PreSaleEvent, PreSaleState> {
  PreSaleBloc() : super(StateLoading()) {
    on<EventRegister>(_registerForPreSale);
    on<EventCheckStatus>(_checkStatus);
  }

  _registerForPreSale(EventRegister data, emit) async {
    emit(StateLoading());
    PreSaleRegistration preSale = await PreSaleRepository.instance.registerForPreSale(data.event);
    emit(StateRegistered(preSale));
  }

  _checkStatus(EventCheckStatus data, emit) async {
    if (!data.event.preSaleAvailable) {
      emit(StatePreSaleNotAvailable());
    } else if (!UserRepository.instance.isLoggedIn) {
      emit(StateNotLoggedIn());
    } else {
      emit(StateLoading());
      PreSaleRegistration? preSale = await PreSaleRepository.instance.isRegisteredForPreSale(data.event);
      if (preSale != null) {
        emit(StateRegistered(preSale));
      } else {
        emit(StateNotRegistered());
      }
    }
  }
}
