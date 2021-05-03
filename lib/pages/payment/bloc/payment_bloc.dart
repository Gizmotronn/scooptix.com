import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stripe_sdk/stripe_sdk_ui.dart';
import 'package:ticketapp/model/discount.dart';
import 'package:ticketapp/model/link_type/link_type.dart';
import 'package:ticketapp/model/ticket_release.dart';
import 'package:ticketapp/repositories/payment_repository.dart';

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc() : super(StateInitial());

  Map<TicketRelease, int> selectedTickets;

  @override
  Stream<PaymentState> mapEventToState(
    PaymentEvent event,
  ) async* {
    if (event is EventLoadAvailableReleases) {
      PaymentRepository.instance.dispose();
      yield* _loadReleases(event.selectedTickets);
    } else if (event is EventConfirmSetupIntent) {
      yield* _savePaymentMethod(event.paymentMethod, event.saveCreditCard);
    } else if (event is EventRequestPI) {
      yield* _createPaymentIntent(event.selectedRelease, event.discount, event.linkType);
    } else if (event is EventRequestFreeTickets) {
      yield* _issueFreeTickets(event.selectedRelease, event.linkType);
    }
  }

  Stream<PaymentState> _createPaymentIntent(
      Map<TicketRelease, int> selectedRelease, Discount discount, LinkType linkType) async* {
    yield StateLoadingPaymentIntent();
    try {
      http.Response response =
          await PaymentRepository.instance.createPaymentIntent(linkType.event, selectedRelease, discount);

      if (response != null) {
        if (response.statusCode == 200) {
          PaymentRepository.instance.clientSecret = json.decode(response.body)["clientSecret"];
          yield* _confirmPayment();
        } else {
          yield StatePaymentError("An unknown error occurred. Please try again.");
        }
      } else {
        yield StatePaymentError("An unknown error occurred. Please try again.");
      }
    } catch (e, _) {
      print(e);
      yield StatePaymentError("An unknown error occurred. Please try again.");
    }
  }

  Stream<PaymentState> _confirmPayment() async* {
    String errorMessage = "An unknown error occurred. Please try again.";
    try {
      Map<String, dynamic> result = await PaymentRepository.instance
          .confirmPayment(PaymentRepository.instance.clientSecret, PaymentRepository.instance.paymentMethodId);
      if (result == null) {
        yield StatePaymentError(errorMessage);
      } else if (result["status"] == "succeeded") {
        yield StatePaymentCompleted(
            "We are processing your order and will send you an email as soon as your tickets are ready. This should not take more than a few minutes.");
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
    yield StateCardUpdated();
    PaymentRepository.instance.saveCreditCard = saveCreditCard;
    if (saveCreditCard) {
      http.Response response = await PaymentRepository.instance.getSetupIntent(true);
      if (response.statusCode == 200) {
        response = await PaymentRepository.instance
            .confirmSetupIntent(payment.id, json.decode(response.body)["setupIntentId"]);

        if (response != null) {
          if (response.statusCode == 200) {
            PaymentRepository.instance.paymentMethodId = payment.id;
            PaymentRepository.instance.last4 = payment.last4;
            yield* _loadReleases(this.selectedTickets);
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

  Stream<PaymentState> _loadReleases(Map<TicketRelease, int> selectedTickets) async* {
    yield StateLoading();
    this.selectedTickets = selectedTickets;
    if (selectedTickets.keys.any((element) => element.price > 0)) {
      if (PaymentRepository.instance.paymentMethodId == null || PaymentRepository.instance.last4 == null) {
        http.Response response = await PaymentRepository.instance.getSetupIntent(false);
        try {
          if (response.statusCode == 200) {
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
      yield StateFreeTicketSelected();
    }
  }

  Stream<PaymentState> _issueFreeTickets(Map<TicketRelease, int> selectedRelease, LinkType linkType) async* {
    yield StateFreeTicketSelected();
  }
}
