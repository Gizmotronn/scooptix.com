import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/model/pre_sale/pre_sale_registration.dart';
import 'package:ticketapp/repositories/presale_repository.dart';
import 'package:ticketapp/repositories/user_repository.dart';

part 'pre_sale_event.dart';
part 'pre_sale_state.dart';

class PreSaleBloc extends Bloc<PreSaleEvent, PreSaleState> {
  PreSaleBloc() : super(StateLoading());

  @override
  Stream<PreSaleState> mapEventToState(
    PreSaleEvent event,
  ) async* {
    if (event is EventRegister) {
      yield* _registerForPreSale(event.event);
    } else if (event is EventCheckStatus) {
      yield* _checkStatus(event.event);
    }
  }

  Stream<PreSaleState> _registerForPreSale(Event event) async* {
    yield StateLoading();
    PreSaleRegistration preSale = await PreSaleRepository.instance.registerForPreSale(event);
    yield StateRegistered(preSale);
  }

  Stream<PreSaleState> _checkStatus(Event event) async* {
    if (!event.preSaleAvailable) {
      yield StatePreSaleNotAvailable();
    } else if (!UserRepository.instance.isLoggedIn) {
      yield StateNotLoggedIn();
    } else {
      yield StateLoading();
      PreSaleRegistration? preSale = await PreSaleRepository.instance.isRegisteredForPreSale(event);
      if (preSale != null) {
        yield StateRegistered(preSale);
      } else {
        yield StateNotRegistered();
      }
    }
  }
}
