import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stripe_sdk/stripe_sdk_ui.dart';
import 'package:ticketapp/model/discount.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/model/ticket.dart';
import 'package:ticketapp/model/ticket_release.dart';
import 'package:ticketapp/repositories/payment_repository.dart';
import 'package:ticketapp/repositories/ticket_repository.dart';
import 'package:ticketapp/repositories/user_repository.dart';

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc() : super(StateInitial()) {
    on<EventLoadAvailableReleases>((event, emit) async {
      PaymentRepository.instance.clear();
      await _loadReleases(event.selectedTickets, event.event, emit);
    });
    on<EventConfirmSetupIntent>(_savePaymentMethod);
    on<EventRequestPI>(_createPaymentIntent);
    on<EventRequestFreeTickets>(_issueFreeTickets);
  }

  Map<TicketRelease, int>? selectedTickets;

  _createPaymentIntent(EventRequestPI event, emit) async {
    emit(StateLoadingPaymentIntent());
    try {
      // It's possible there are free tickets selected as well, we only want to process paid ones here
      Map<TicketRelease, int> paidReleases = {};
      Map<TicketRelease, int> freeReleases = {};
      event.selectedRelease.forEach((key, value) {
        if (key.price != 0) {
          paidReleases[key] = value;
        } else {
          freeReleases[key] = value;
        }
      });
      bool ticketsStillAvailable =
          await TicketRepository.instance.checkTicketsStillAvailable(event.event, paidReleases);
      bool discountsStillAvailable = event.discount == null ||
          await TicketRepository.instance.checkDiscountsStillAvailable(event.event, event.discount!,
              paidReleases.values.fold(0, (int previousValue, int element) => previousValue + element));
      if (!ticketsStillAvailable) {
        emit(StatePaymentError("The selected tickets are no longer available"));
        PaymentRepository.instance.releaseDataUpdatedStream.add(true);
      } else if (!discountsStillAvailable) {
        emit(StatePaymentError("The selected discount is no longer available"));
        PaymentRepository.instance.releaseDataUpdatedStream.add(true);
      } else {
        http.Response? response =
            await PaymentRepository.instance.createPaymentIntent(event.event, paidReleases, event.discount);

        if (response != null) {
          if (response.statusCode == 200) {
            PaymentRepository.instance.clientSecret = json.decode(response.body)["clientSecret"];
            await _confirmPayment(emit,
                freeReleases: freeReleases,
                event: event.event,
                discount: event.discount,
                ticketQuantity:
                    paidReleases.values.fold(0, (int a, int b) => a + b) + freeReleases.values.fold(0, (a, b) => a + b),
                context: event.context);
          } else {
            emit(StatePaymentError("An unknown error occurred. Please try again."));
          }
        } else {
          emit(StatePaymentError("An unknown error occurred. Please try again."));
        }
      }
    } catch (e, _) {
      print(e);
      emit(StatePaymentError("An unknown error occurred. Please try again."));
    }
  }

  _confirmPayment(emit,
      {Map<TicketRelease, int>? freeReleases,
      Event? event,
      int ticketQuantity = 1,
      Discount? discount,
      required BuildContext context}) async {
    assert(freeReleases == null || event != null);

    try {
      Map<String, dynamic> result = await PaymentRepository.instance.confirmPayment(
          PaymentRepository.instance.clientSecret!, PaymentRepository.instance.paymentMethodId!, context);
      if (result["status"] == "succeeded") {
        TicketRepository.instance.incrementLinkTicketsBoughtCounter(event!, ticketQuantity);

        PaymentRepository.instance.releaseDataUpdatedStream.add(true);
        // If there were free tickets to process as well, do this here.
        // This assures that free tickets are only issued if the paid tickets were issued successfully.
        // Issuing free tickets should never fail.
        if (freeReleases != null && freeReleases.isNotEmpty) {
          freeReleases.keys.forEach((element) async {
            await TicketRepository.instance.acceptInvitation(event, element);
          });
        }
        emit(StatePaymentCompleted(
            "We are processing your order and will send you an email as soon as your tickets are ready. This should not take more than a few minutes."));
        PaymentRepository.instance.clear();
      } else {
        emit(StatePaymentError(result.toString()));
      }
    } catch (e) {
      print(e);
      emit(StatePaymentError(e.toString()));
    }
  }

  _savePaymentMethod(EventConfirmSetupIntent event, emit) async {
    emit(StateCardUpdated());
    PaymentRepository.instance.saveCreditCard = event.saveCreditCard;
    if (event.saveCreditCard) {
      http.Response? response = await PaymentRepository.instance.getSetupIntent(true);
      if (response != null && response.statusCode == 200) {
        response = await PaymentRepository.instance
            .confirmSetupIntent(event.paymentMethod.id, json.decode(response.body)["setupIntentId"]);

        if (response != null) {
          if (response.statusCode == 200) {
            PaymentRepository.instance.paymentMethodId = event.paymentMethod.id;
            PaymentRepository.instance.last4 = event.paymentMethod.last4;
            emit(_loadReleases(selectedTickets!, event.event, emit));
          } else {
            emit(StatePaymentError(response.toString()));
          }
        } else {
          emit(StatePaymentError("An unknown error occurred. Please try again."));
        }
      }
    } else {
      PaymentRepository.instance.paymentMethodId = event.paymentMethod.id;
      PaymentRepository.instance.last4 = event.paymentMethod.last4;
      emit(StatePaidTickets());
    }
  }

  _loadReleases(Map<TicketRelease, int> selectedTickets, Event event, emit) async {
    emit(StateLoading());
    this.selectedTickets = selectedTickets;
    if (selectedTickets.keys.any((element) => element.price! > 0)) {
      if (PaymentRepository.instance.paymentMethodId == null || PaymentRepository.instance.last4 == null) {
        http.Response? response = await PaymentRepository.instance.getSetupIntent(false);
        try {
          if (response != null && response.statusCode == 200) {
            if (json.decode(response.body)["requiresConfirmation"] == false) {
              print(json.decode(response.body)["paymentMethod"]);
              PaymentRepository.instance.paymentMethodId = json.decode(response.body)["paymentMethod"];
              PaymentRepository.instance.last4 = json.decode(response.body)["last4"];
            }
            emit(StatePaidTickets());
          } else {
            emit(StatePaymentError("An unknown error occurred. Please try again."));
          }
        } catch (e) {
          print(e);
          emit(StatePaymentError("An unknown error occurred. Please try again."));
        }
      } else {
        emit(StatePaidTickets());
      }
    } else {
      List<Future<List<Ticket>>> ownedTicketsFutures = [];
      selectedTickets.keys.where((element) => element.price == 0).forEach((element) {
        ownedTicketsFutures.add(TicketRepository.instance
            .loadTickets(UserRepository.instance.currentUser()!.firebaseUserID, event, release: element));
      });
      List<List<Ticket>> ownedTickets = await Future.wait(ownedTicketsFutures);
      if (ownedTickets.any((element) => element.isNotEmpty)) {
        emit(StateFreeTicketAlreadyOwned());
      } else {
        emit(StateFreeTicketSelected());
      }
    }
  }

  _issueFreeTickets(EventRequestFreeTickets event, emit) async {
    emit(StateLoading());
    event.selectedRelease.keys.forEach((element) async {
      await TicketRepository.instance.acceptInvitation(event.event, element);
    });
    emit(StatePaymentCompleted(
        "We are processing your order and will send you an email as soon as your tickets are ready. This should not take more than a few minutes."));
  }
}
