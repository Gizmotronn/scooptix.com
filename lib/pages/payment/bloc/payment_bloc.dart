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
    } else if(event is EventTicketSelected){
      yield* _selectTicket(event.selectedRelease, event.availableReleases);
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
        yield* _confirmPayment(selectedRelease, quantity);
      } else {
        yield StatePaymentError("An unknown error occurred. Please try again.");
      }
    } catch (e, s){
      print(e);
      yield StatePaymentError("An unknown error occurred. Please try again.");
    }
  }

  Stream<PaymentState> _confirmPayment(TicketRelease selectedRelease, int quantity) async* {
    String errorMessage = "An unknown error occurred. Please try again.";
    try {
      Map<String, dynamic> result =
          await PaymentRepository.instance.confirmPayment(PaymentRepository.instance.clientSecret, PaymentRepository.instance.paymentMethodId);
      print(result);
      if (result == null) {
        yield StatePaymentError(errorMessage);
      } else if (result["status"] == "succeeded") {
        yield StatePaymentCompleted(
            "We are processing your order and will send you an email as soon as your tickets are ready. This should not take more than a few minutes.",selectedRelease, quantity);
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

    List<TicketRelease> releases = event.getAllReleases();

    if (releases.any((element) => element.price > 0)) {
      if (PaymentRepository.instance.paymentMethodId == null || PaymentRepository.instance.last4 == null) {
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

      if (releases.length > 0) {
        if (releases[0].price > 0) {
          if (releases[0].singleTicketRestriction) {
            yield StatePaidTicketSelected(releases, releases[0]);
          } else {
            yield StatePaidTicketQuantitySelected(releases, releases[0]);
          }
        } else {
          if (releases[0].singleTicketRestriction) {
            yield StateFreeTicketSelected(releases, releases[0]);
          } else {
            // NOT IMPLEMENTED YET
            // Not sure yet if this will be a feature yet
            // yield StateFreeTicketQuantitySelected(releasesWithRegularTickets, releasesWithRegularTickets[0]);
            yield StateFreeTicketSelected(releases, releases[0]);
          }
        }
      }
      else {
        yield StateNoTicketsAvailable();
      }
    }
  }

  Stream<PaymentState> _selectTicket(TicketRelease selectedRelease, List<TicketRelease> availableReleases) async* {
    yield StateUpdating();
    if(selectedRelease.price == 0){
      if(selectedRelease.singleTicketRestriction){
        yield StateFreeTicketSelected(availableReleases, selectedRelease);
      } else {
        yield StateFreeTicketSelected(availableReleases, selectedRelease);
        // NOT IMPLEMENTED YET
        // Not sure yet if this will be a feature yet
        // yield StateFreeTicketQuantitySelected(availableReleases, selectedRelease);
      }
    } else {
      if(selectedRelease.singleTicketRestriction){
        yield StatePaidTicketSelected(availableReleases, selectedRelease);
      } else {
        yield StatePaidTicketQuantitySelected(availableReleases, selectedRelease);
      }
    }

  }
}
