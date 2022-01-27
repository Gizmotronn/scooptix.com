import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ticketapp/model/discount.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/repositories/ticket_repository.dart';

part 'ticket_event.dart';
part 'ticket_state.dart';

class TicketBloc extends Bloc<TicketEvent, TicketState> {
  TicketBloc() : super(StateLoading(message: "Fetching your invitation data, this won't take long ...")){
    on<EventApplyDiscount>(_applyDiscount);
    on<EventRemoveDiscount>((event, emit) => emit(StateDiscountCodeRemoved()));
  }

  _applyDiscount(EventApplyDiscount event, emit) async {
    emit(StateDiscountCodeLoading());
    Discount? discount = await TicketRepository.instance.loadDiscount(event.event, event.code);
    if (discount == null || discount.maxUses < discount.timesUsed + event.quantity) {
      emit(StateDiscountCodeInvalid());
    } else {
      emit(StateDiscountApplied(discount));
    }
  }
}
