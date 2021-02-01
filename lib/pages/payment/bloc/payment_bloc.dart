import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stripe_sdk/stripe_sdk_ui.dart';
import 'package:webapp/model/event.dart';
import 'package:webapp/model/ticket_release.dart';
import 'package:webapp/repositories/payment_repository.dart';

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc({this.paymentMethodId, this.clientSecret, this.last4}) : super(StateInitial());

  String clientSecret;
  String paymentMethodId;
  String last4;
  Event event;
  TicketRelease selectedRelease;
  List<TicketRelease> availableReleases = [];
  int quantity;

  @override
  Stream<PaymentState> mapEventToState(
    PaymentEvent event,
  ) async* {
    if (event is EventLoadAvailableReleases) {
      yield* _loadReleases(event.event);
    } else if (event is EventConfirmPayment) {
      yield* _confirmPayment();
    } else if (event is EventConfirmSetupIntent) {
      yield* _confirmSetupIntent(event.paymentMethod, event.setupIntentId);
    } else if (event is EventStartPaymentProcess) {
      yield* _getSetupIntent(event.release, event.quantity, false);
    } else if (event is EventRequestPI) {
      yield* _createPaymentIntent();
    } else if(event is EventCancelPayment){
      yield StateReleasesLoaded(this.availableReleases);
    } else if(event is EventChangePaymentMethod){
      yield* _getSetupIntent(this.selectedRelease, this.quantity, true);
    }
  }

  Stream<PaymentState> _getSetupIntent(TicketRelease release, int quantity, bool newPaymentMethod) async* {
    yield StateLoadingPaymentMethod();
    this.selectedRelease = release;
    this.quantity = quantity;
    http.Response response = await PaymentRepository.instance.getSetupIntent(newPaymentMethod);
    try {
      if (response.statusCode == 200) {
        print(response.body);
        this.paymentMethodId = json.decode(response.body)["paymentMethod"];
        this.last4 = json.decode(response.body)["last4"];
        if (json.decode(response.body)["requiresConfirmation"] == false) {
          yield* _createPaymentIntent();
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

  Stream<PaymentState> _createPaymentIntent() async* {
    yield StateLoadingPaymentIntent();
    http.Response response =
        await PaymentRepository.instance.createPaymentIntent(event.docID, selectedRelease.docId, quantity);
    this.clientSecret = json.decode(response.body)["clientSecret"];

    if (response.statusCode == 200) {
      yield StateFinalizePayment(this.last4, json.decode(response.body)["price"],
          json.decode(response.body)["clientSecret"], this.paymentMethodId, this.quantity);
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
      yield* _createPaymentIntent();
    } else {
      yield StatePaymentError("An unknown error occurred. Please try again.");
    }
  }

  Stream<PaymentState> _loadReleases(Event event) async* {
    yield StateLoading();
    this.event = event;
    List<TicketRelease> releases = [];
    event.releaseManagers.forEach((manager) {
      TicketRelease release = manager.getActiveRelease();
      if (release != null && release.price != 0) {
        release.name = manager.name + " - " + release.name + " release";
        releases.add(release);
      }
    });
    this.availableReleases = releases;
    if(releases.length > 0) {
      yield StateReleasesLoaded(releases);
    } else {
      yield StateNoTicketsAvailable();
    }
  }
}
