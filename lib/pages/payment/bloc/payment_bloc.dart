import 'dart:async';
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
  PaymentBloc() : super(StateInitial());

  Map<TicketRelease, int>? selectedTickets;

  @override
  Stream<PaymentState> mapEventToState(
    PaymentEvent event,
  ) async* {
    if (event is EventLoadAvailableReleases) {
      PaymentRepository.instance.clear();
      yield* _loadReleases(event.selectedTickets, event.event);
    } else if (event is EventConfirmSetupIntent) {
      yield* _savePaymentMethod(event.paymentMethod, event.saveCreditCard, event.event);
    } else if (event is EventRequestPI) {
      yield* _createPaymentIntent(event.selectedRelease, event.discount, event.event);
    } else if (event is EventRequestFreeTickets) {
      yield* _issueFreeTickets(event.selectedRelease, event.event);
    }
  }

  Stream<PaymentState> _createPaymentIntent(
      Map<TicketRelease, int> selectedReleases, Discount? discount, Event event) async* {
    yield StateLoadingPaymentIntent();
    try {
      // It's possible there are free tickets selected as well, we only want to process paid ones here
      Map<TicketRelease, int> paidReleases = {};
      Map<TicketRelease, int> freeReleases = {};
      selectedReleases.forEach((key, value) {
        if (key.price != 0) {
          paidReleases[key] = value;
        } else {
          freeReleases[key] = value;
        }
      });
      bool stillAvailable = await TicketRepository.instance.checkTicketsStillAvailable(event, paidReleases);
      if (!stillAvailable) {
        yield StatePaymentError("The selected tickets are no longer available");
      } else {
        http.Response? response = await PaymentRepository.instance.createPaymentIntent(event, paidReleases, discount);

        if (response != null) {
          if (response.statusCode == 200) {
            PaymentRepository.instance.clientSecret = json.decode(response.body)["clientSecret"];
            yield* _confirmPayment(
                freeReleases: freeReleases,
                event: event,
                discount: discount,
                ticketQuantity: paidReleases.values.fold(0, (int a, int b) => a + b) +
                    freeReleases.values.fold(0, (a, b) => a + b));
          } else {
            yield StatePaymentError("An unknown error occurred. Please try again.");
          }
        } else {
          yield StatePaymentError("An unknown error occurred. Please try again.");
        }
      }
    } catch (e, _) {
      print(e);
      yield StatePaymentError("An unknown error occurred. Please try again.");
    }
  }

  Stream<PaymentState> _confirmPayment(
      {Map<TicketRelease, int>? freeReleases, Event? event, int ticketQuantity = 1, Discount? discount}) async* {
    assert(freeReleases == null || event != null);

    try {
      Map<String, dynamic> result = await PaymentRepository.instance
          .confirmPayment(PaymentRepository.instance.clientSecret!, PaymentRepository.instance.paymentMethodId!);
      if (result["status"] == "succeeded") {
        TicketRepository.instance.incrementLinkTicketsBoughtCounter(event!, ticketQuantity);
        if (discount != null) {
          TicketRepository.instance.incrementDiscountCounter(event, discount, ticketQuantity);
        }
        PaymentRepository.instance.releaseDataUpdatedStream.add(true);
        // If there were free tickets to process as well, do this here.
        // This assures that free tickets are only issued if the paid tickets were issued successfully.
        // Issuing free tickets should never fail.
        if (freeReleases != null && freeReleases.isNotEmpty) {
          freeReleases.keys.forEach((element) async {
            await TicketRepository.instance.acceptInvitation(event, element);
          });
        }
        yield StatePaymentCompleted(
            "We are processing your order and will send you an email as soon as your tickets are ready. This should not take more than a few minutes.");
        PaymentRepository.instance.clear();
      } else {
        yield StatePaymentError(result.toString());
      }
    } catch (e) {
      print(e);
      yield StatePaymentError(e.toString());
    }
  }

  Stream<PaymentState> _savePaymentMethod(PaymentMethod payment, bool saveCreditCard, Event event) async* {
    yield StateCardUpdated();
    PaymentRepository.instance.saveCreditCard = saveCreditCard;
    if (saveCreditCard) {
      http.Response? response = await PaymentRepository.instance.getSetupIntent(true);
      if (response != null && response.statusCode == 200) {
        response = await PaymentRepository.instance
            .confirmSetupIntent(payment.id, json.decode(response.body)["setupIntentId"]);

        if (response != null) {
          if (response.statusCode == 200) {
            PaymentRepository.instance.paymentMethodId = payment.id;
            PaymentRepository.instance.last4 = payment.last4;
            yield* _loadReleases(this.selectedTickets!, event);
          } else {
            yield StatePaymentError(response.toString());
          }
        } else {
          yield StatePaymentError("An unknown error occurred. Please try again.");
        }
      }
    } else {
      PaymentRepository.instance.paymentMethodId = payment.id;
      PaymentRepository.instance.last4 = payment.last4;
      yield StatePaidTickets();
    }
  }

  Stream<PaymentState> _loadReleases(Map<TicketRelease, int> selectedTickets, Event event) async* {
    yield StateLoading();
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
            yield StatePaidTickets();
          } else {
            yield StatePaymentError("An unknown error occurred. Please try again.");
          }
        } catch (e) {
          print(e);
          yield StatePaymentError("An unknown error occurred. Please try again.");
        }
      } else {
        yield StatePaidTickets();
      }
    } else {
      List<Future<List<Ticket>>> ownedTicketsFutures = [];
      selectedTickets.keys.where((element) => element.price == 0).forEach((element) {
        ownedTicketsFutures.add(TicketRepository.instance
            .loadTickets(UserRepository.instance.currentUser()!.firebaseUserID, event, release: element));
      });
      List<List<Ticket>> ownedTickets = await Future.wait(ownedTicketsFutures);
      if (ownedTickets.any((element) => element.isNotEmpty)) {
        yield StateFreeTicketAlreadyOwned();
      } else {
        yield StateFreeTicketSelected();
      }
    }
  }

  Stream<PaymentState> _issueFreeTickets(Map<TicketRelease, int> selectedRelease, Event event) async* {
    yield StateLoading();
    selectedRelease.keys.forEach((element) async {
      await TicketRepository.instance.acceptInvitation(event, element);
    });
    yield StatePaymentCompleted(
        "We are processing your order and will send you an email as soon as your tickets are ready. This should not take more than a few minutes.");
  }
}
