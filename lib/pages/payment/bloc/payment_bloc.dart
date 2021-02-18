import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stripe_sdk/stripe_sdk_ui.dart';
import 'package:webapp/model/discount.dart';
import 'package:webapp/model/event.dart';
import 'package:webapp/model/release_manager.dart';
import 'package:webapp/model/ticket_release.dart';
import 'package:webapp/repositories/payment_repository.dart';
import 'package:webapp/repositories/ticket_repository.dart';

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc() : super(StateInitial());

  Event event;

  @override
  Stream<PaymentState> mapEventToState(
    PaymentEvent event,
  ) async* {
    if (event is EventLoadAvailableReleases) {
      PaymentRepository.instance.dispose();
      yield* _loadReleases(event.event);
    } else if (event is EventConfirmSetupIntent) {
      yield* _savePaymentMethod(event.paymentMethod, event.saveCreditCard);
    } else if (event is EventRequestPI) {
      yield* _createPaymentIntent(event.selectedRelease, event.quantity, event.discount);
    } else if (event is EventCancelPayment) {
      yield* _loadReleases(this.event);
    } else if (event is EventChangePaymentMethod) {
      yield* _getSetupIntent(true);
    } else if (event is EventAddPaymentMethod) {
      yield StateAddPaymentMethod();
    } else if (event is EventTicketSelected) {
      yield* _selectTicket(event.selectedRelease, event.managers);
    } else if (event is EventApplyDiscount) {
      yield* _applyDiscount(event.code, event.selectedRelease);
    }
  }

  Stream<PaymentState> _getSetupIntent(bool newPaymentMethod) async* {
    yield StateLoadingPaymentMethod();
    http.Response response = await PaymentRepository.instance.getSetupIntent(newPaymentMethod);
    try {
      if (response.statusCode == 200) {
        print(response.body);
        PaymentRepository.instance.paymentMethodId = json.decode(response.body)["paymentMethod"];
        PaymentRepository.instance.last4 = json.decode(response.body)["last4"];
        if (json.decode(response.body)["requiresConfirmation"] == false) {
          //yield* _createPaymentIntent();
        } else {
          yield StateSIRequiresPaymentMethod(json.decode(response.body)["setupIntentId"]);
        }
      } else {
        yield StatePaymentError("An unknown error occurred. Please try again.");
      }
    } catch (e) {
      print(e);
    }
  }

  Stream<PaymentState> _createPaymentIntent(TicketRelease selectedRelease, int quantity, Discount discount) async* {
    yield StateLoadingPaymentIntent();
    try {
      http.Response response = await PaymentRepository.instance.createPaymentIntent(
          event.docID,
          event.releaseManagers.firstWhere((element) => element.releases.contains(selectedRelease)).docId,
          selectedRelease.docId,
          quantity,
          discount);

      if (response != null) {
        if (response.statusCode == 200) {
          PaymentRepository.instance.clientSecret = json.decode(response.body)["clientSecret"];
          yield* _confirmPayment(selectedRelease, quantity);
        } else {
          yield StatePaymentError("An unknown error occurred. Please try again.");
        }
      } else {
        yield StatePaymentError("An unknown error occurred. Please try again.");
      }
    } catch (e, s) {
      print(e);
      yield StatePaymentError("An unknown error occurred. Please try again.");
    }
  }

  Stream<PaymentState> _confirmPayment(TicketRelease selectedRelease, int quantity) async* {
    String errorMessage = "An unknown error occurred. Please try again.";
    try {
      Map<String, dynamic> result = await PaymentRepository.instance
          .confirmPayment(PaymentRepository.instance.clientSecret, PaymentRepository.instance.paymentMethodId);
      if (result == null) {
        yield StatePaymentError(errorMessage);
      } else if (result["status"] == "succeeded") {
        yield StatePaymentCompleted(
            "We are processing your order and will send you an email as soon as your tickets are ready. This should not take more than a few minutes.",
            selectedRelease,
            quantity);
        PaymentRepository.instance.dispose();
      } else {
        yield StatePaymentError(result.toString());
      }
    } catch (e) {
      print(e);
      yield StatePaymentError(e.toString());
    }
  }

  Stream<PaymentState> _savePaymentMethod(PaymentMethod payment, bool saveCreditCard) async* {
    yield StateLoading();
    PaymentRepository.instance.saveCreditCard = saveCreditCard;
    if (saveCreditCard) {
      print("saving credit card");
      http.Response response = await PaymentRepository.instance.getSetupIntent(true);
      if (response.statusCode == 200) {
        response = await PaymentRepository.instance
            .confirmSetupIntent(payment.id, json.decode(response.body)["setupIntentId"]);

        if (response != null) {
          if (response.statusCode == 200) {
            PaymentRepository.instance.paymentMethodId = payment.id;
            PaymentRepository.instance.last4 = payment.last4;
            yield* _loadReleases(this.event);
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
      print(PaymentRepository.instance.last4);
      yield* _loadReleases(this.event);
    }
  }

  Stream<PaymentState> _loadReleases(Event event) async* {
    yield StateLoading();
    this.event = event;

    List<ReleaseManager> managers = event.getManagersWithActiveReleases();

    if (managers.any((element) => element.getActiveRelease().price > 0)) {
      if (PaymentRepository.instance.paymentMethodId == null || PaymentRepository.instance.last4 == null) {
        http.Response response = await PaymentRepository.instance.getSetupIntent(false);
        try {
          if (response.statusCode == 200) {
            if (json.decode(response.body)["requiresConfirmation"] == false) {
              print(json.decode(response.body)["paymentMethod"]);
              PaymentRepository.instance.paymentMethodId = json.decode(response.body)["paymentMethod"];
              PaymentRepository.instance.last4 = json.decode(response.body)["last4"];
            }
          } else {
            yield StatePaymentError("An unknown error occurred. Please try again.");
          }
        } catch (e) {
          print(e);
        }
      }
    }

    if (managers.length > 0) {
      if (managers[0].getActiveRelease().price > 0) {
        if (managers[0].getActiveRelease().singleTicketRestriction) {
          yield StatePaidTicketSelected(managers);
        } else {
          yield StatePaidTicketQuantitySelected(managers);
        }
      } else {
        if (managers[0].getActiveRelease().singleTicketRestriction) {
          yield StateFreeTicketSelected(managers);
        } else {
          // NOT IMPLEMENTED YET
          // Not sure yet if this will be a feature yet
          // yield StateFreeTicketQuantitySelected(releasesWithRegularTickets, releasesWithRegularTickets[0]);
          yield StateFreeTicketSelected(managers);
        }
      }
    } else {
      yield StateNoTicketsAvailable();
    }
  }

  Stream<PaymentState> _selectTicket(TicketRelease selectedRelease, List<ReleaseManager> managers) async* {
    yield StateUpdating();
    if (selectedRelease.price == 0) {
      if (selectedRelease.singleTicketRestriction) {
        yield StateFreeTicketSelected(managers);
      } else {
        yield StateFreeTicketSelected(managers);
        // NOT IMPLEMENTED YET
        // Not sure yet if this will be a feature yet
        // yield StateFreeTicketQuantitySelected(availableReleases, selectedRelease);
      }
    } else {
      if (selectedRelease.singleTicketRestriction) {
        yield StatePaidTicketSelected(managers);
      } else {
        yield StatePaidTicketQuantitySelected(managers);
      }
    }
  }

  Stream<PaymentState> _applyDiscount(String code, TicketRelease selectedRelease) async* {
    yield StateDiscountCodeLoading();
    Discount discount = await TicketRepository.instance.loadDiscount(this.event, code);
    if (discount == null) {
      yield StateDiscountCodeInvalid();
    }
    if (selectedRelease.singleTicketRestriction) {
      yield StatePaidTicketSelected(event.getAllReleases(), discount: discount);
    } else {
      yield StatePaidTicketQuantitySelected(event.getAllReleases(), discount: discount);
    }
  }
}
