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
  PaymentBloc() : super(StateInitial());

  Event event;
  List<TicketRelease> availableReleases = [];

  @override
  Stream<PaymentState> mapEventToState(
    PaymentEvent event,
  ) async* {
    if (event is EventLoadAvailableReleases) {
      yield* _loadReleases(event.event);
    } else if (event is EventConfirmSetupIntent) {
      yield* _savePaymentMethod(event.paymentMethod);
    } else if (event is EventRequestPI) {
      yield* _createPaymentIntent(event.selectedRelease, event.quantity);
    } else if(event is EventCancelPayment){
      yield* _loadReleases(this.event);
    } else if(event is EventChangePaymentMethod){
      yield* _getSetupIntent(true);
    } else if (event is EventAddPaymentMethod){
      yield StateAddPaymentMethod();
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

  Stream<PaymentState> _createPaymentIntent(TicketRelease selectedRelease, int quantity) async* {
    yield StateLoadingPaymentIntent();
    try {
      http.Response response =
      await PaymentRepository.instance.createPaymentIntent(event.docID, event.releaseManagers
          .firstWhere((element) => element.releases.contains(selectedRelease))
          .docId, selectedRelease.docId, quantity);

      if (response.statusCode == 200) {
        PaymentRepository.instance.clientSecret = json.decode(response.body)["clientSecret"];
        yield* _confirmPayment();
      } else {
        yield StatePaymentError("An unknown error occurred. Please try again.");
      }
    } catch (e, s){
      print(e);
      yield StatePaymentError("An unknown error occurred. Please try again.");
    }
  }

  Stream<PaymentState> _confirmPayment() async* {
    yield StateLoading();
    String errorMessage = "An unknown error occurred. Please try again.";
    try {
      Map<String, dynamic> result =
          await PaymentRepository.instance.confirmPayment(PaymentRepository.instance.clientSecret, PaymentRepository.instance.paymentMethodId);
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

  Stream<PaymentState> _savePaymentMethod(PaymentMethod payment) async* {
    yield StateLoading();
    http.Response response = await PaymentRepository.instance.getSetupIntent(true);
    if (response.statusCode == 200) {
      response = await PaymentRepository.instance.confirmSetupIntent(payment.id, json.decode(response.body)["setupIntentId"]);

      PaymentRepository.instance.paymentMethodId = payment.id;
      PaymentRepository.instance.last4 = payment.last4;

      if (response.statusCode == 200) {
        yield* _loadReleases(this.event);
      } else {
        yield StatePaymentError("An unknown error occurred. Please try again.");
      }
    }
  }

  Stream<PaymentState> _loadReleases(Event event) async* {
    yield StateLoading();
    this.event = event;

    List<TicketRelease> releasesWithSingleTicketRestriction = event.getReleasesWithSingleTicketRestriction();
    List<TicketRelease> releasesWithRegularTickets = event.getReleasesWithoutRestriction();

    if(releasesWithSingleTicketRestriction.any((element) => element.price > 0 || releasesWithRegularTickets.any((element) => element.price > 0))){
      if(PaymentRepository.instance.paymentMethodId == null || PaymentRepository.instance.last4 == null) {
        http.Response response = await PaymentRepository.instance.getSetupIntent(false);
        try {
          if (response.statusCode == 200) {
            if (json.decode(response.body)["requiresConfirmation"] == false) {
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

      if(releasesWithSingleTicketRestriction.length > 0 ){
        yield StatePaymentRequired(releasesWithSingleTicketRestriction);
      } else {
        yield StatePaymentRequired(releasesWithRegularTickets);
      }

    } else if(releasesWithSingleTicketRestriction.length > 0 ){
      yield StateNoPaymentRequired(releasesWithSingleTicketRestriction);
    } else if(releasesWithRegularTickets.length > 0){
      yield StateNoPaymentRequired(releasesWithRegularTickets);
    } else {
      yield StateNoTicketsAvailable();
    }
  }
}
