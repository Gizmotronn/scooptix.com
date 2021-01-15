import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stripe_sdk/stripe_sdk_ui.dart';
import 'package:webapp/repositories/payment_repository.dart';

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc({this.paymentMethodId, this.clientSecret, this.last4}) : super(StateInitial());

  String clientSecret;
  String paymentMethodId;
  String last4;

  @override
  Stream<PaymentState> mapEventToState(
    PaymentEvent event,
  ) async* {
    if(event is EventConfirmPayment){
      yield* _confirmPayment();
    } else if(event is EventConfirmSetupIntent){
      yield* _confirmSetupIntent(event.paymentMethod, event.setupIntentId);
    }else if(event is EventGetSetupIntent){
      yield* _getSetupIntent();
    }else if(event is EventRequestPI){
      yield* _createPaymentIntent(event.eventId, event.ticketId, event.quantity);
    }
  }


  Stream<PaymentState> _getSetupIntent() async* {
    yield StateLoading();
    http.Response response = await PaymentRepository.instance.getSetupIntent(false);
    try {
      if (response.statusCode == 200) {print(response.body);
        this.paymentMethodId = json.decode(response.body)["paymentMethod"];
        this.last4 = json.decode(response.body)["last4"];
        if (json.decode(response.body)["requiresConfirmation"] == false) {
          /*http.Response confirmResponse = await PaymentRepository.instance
              .confirmSetupIntent(json.decode(response.body)['paymentId'], json.decode(response.body)['setupIntentId']);*/

          yield SetupIntentConfirmedState(json.decode(response.body)["last4"]);
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

  Stream<PaymentState> _createPaymentIntent(String eventId, String ticketId, int quantity) async* {
    yield StateLoading();
    http.Response response = await PaymentRepository.instance.createPaymentIntent(eventId,ticketId , quantity);
    this.clientSecret = json.decode(response.body)["clientSecret"];

    if (response.statusCode == 200) {
      yield StateFinalizePayment(this.last4, json.decode(response.body)["price"],
          json.decode(response.body)["clientSecret"], this.paymentMethodId);
    } else {
      yield StatePaymentError("An unknown error occurred. Please try again.");
    }
  }

  Stream<PaymentState> _confirmPayment() async* {
    yield StateLoading();
    String errorMessage = "An unknown error occurred. Please try again.";
    try {

        Map<String, dynamic> result =
        await PaymentRepository.instance.confirmPayment(this.clientSecret, this.paymentMethodId);
        print(result);
        if (result == null) {
          yield StatePaymentError(errorMessage);
        } else if (result["status"] == "succeeded") {
          yield PaymentCompletedState(
              "We are processing your order and will send you a message as soon as your new subscription is active. This should not take more than a few minutes.");
        } else {
          yield StatePaymentError(errorMessage);
        }
    } catch (e) {
      print(e);
      yield StatePaymentError(errorMessage);
    }
  }


  Stream<PaymentState> _confirmSetupIntent(PaymentMethod payment, String setupIntentId) async* {
    yield StateLoading();
    http.Response response = await PaymentRepository.instance.confirmSetupIntent(payment.id, setupIntentId);

    this.paymentMethodId = payment.id;
    this.last4 = payment.last4;
    if (response.statusCode == 200) {
      yield SetupIntentConfirmedState(this.last4);
    } else {
      yield StatePaymentError("An unknown error occurred. Please try again.");
    }
  }
}
