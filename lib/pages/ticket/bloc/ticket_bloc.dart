import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ticketapp/model/discount.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/repositories/ticket_repository.dart';

part 'ticket_event.dart';
part 'ticket_state.dart';

class TicketBloc extends Bloc<TicketEvent, TicketState> {
  TicketBloc() : super(StateLoading(message: "Fetching your invitation data, this won't take long ..."));

  @override
  Stream<TicketState> mapEventToState(
    TicketEvent event,
  ) async* {
    if (event is EventApplyDiscount) {
      yield* _applyDiscount(event.event, event.code);
    }
  }

  Stream<TicketState> _applyDiscount(Event event, String code) async* {
    yield StateDiscountCodeLoading();
    Discount discount = await TicketRepository.instance.loadDiscount(event, code);
    if (discount == null) {
      yield StateDiscountCodeInvalid();
    } else {
      yield StateDiscountApplied(discount);
    }
  }
}
