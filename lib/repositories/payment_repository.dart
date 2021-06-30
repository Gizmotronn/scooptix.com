import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:stripe_sdk/stripe_sdk.dart';
import 'package:ticketapp/model/discount.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/model/ticket_release.dart';
import 'package:ticketapp/repositories/user_repository.dart';

enum PaymentType { FashionItemSale, DesignerSubscription }

class PaymentRepository {
  static PaymentRepository _instance;

  static PaymentRepository get instance {
    if (_instance == null) {
      _instance = new PaymentRepository._();
      _instance.releaseDataUpdatedStream = StreamController.broadcast();
      Stripe.init(
          "pk_test_51HFJF6CE1hbokQY3T40M55NEswDQti67gfDeSVUTvymGQI5TnDeesnK0n0R1lYLn0B09at5jPgeHebh65bMCtGwL00RipFf2qB",
          returnUrlForSca: "https://appollo.io/success");
    }
    return _instance;
  }

  clear() {
    clientSecret = null;
    paymentMethodId = null;
    last4 = null;
    saveCreditCard = false;
  }

  dispose() {
    clear();
    releaseDataUpdatedStream.close();
    _instance = null;
  }

  PaymentRepository._();

  String clientSecret;
  String paymentMethodId;
  String last4;
  bool saveCreditCard = false;

  StreamController<bool> releaseDataUpdatedStream;

  /// Checks if the payment is valid an confirms the payment with stripe.
  /// Ticket creation and final validity check are handled by the stripe webhook CF
  Future<Map<String, dynamic>> confirmPayment(String clientSecret, String paymentId) async {
    return await Stripe.instance.confirmPayment(clientSecret, paymentMethodId: paymentId);
  }

  Future<http.Response> createPaymentIntent(
      Event event, Map<TicketRelease, int> selectedTickets, Discount discount) async {
    print(discount);
    try {
      http.Response response = await http.post(Uri.parse("https://appollo-devops.web.app/createPITicketSale"), body: {
        "event": event.docID,
        "manager": json.encode(selectedTickets.keys.map((e) => event.getReleaseManager(e).docId).toList()),
        "ticketRelease": json.encode(selectedTickets.keys.map((e) => e.docId).toList()),
        "quantity": json.encode(selectedTickets.values.toList()),
        "discount": discount == null ? "" : discount.docId,
        "pmId": !PaymentRepository.instance.saveCreditCard ? PaymentRepository.instance.paymentMethodId : "",
        "user": UserRepository.instance.currentUser().firebaseUserID
      });
      return response;
    } on Exception catch (ex) {
      print(ex);
      return null;
    }
  }

  /// Retrieves the users Stripe customer account or creates one if none exists.
  /// Retrieves a SetupIntent from an existing Payment Method, or if none exists a SetupIntent that requires confirmation with a PaymentMethod
  /// Setting [forceNewPaymentMethod] to true ignores any stored payment methods.
  Future<http.Response> getSetupIntent(bool forceNewPaymentMethod) async {
    try {
      http.Response response = await http.post(Uri.parse("https://appollo-devops.web.app/getSetupIntent"), body: {
        "user": UserRepository.instance.currentUser().firebaseUserID,
        "forceNewPaymentMethod": forceNewPaymentMethod.toString()
      });
      return response;
    } on Exception catch (ex) {
      print(ex);
      return null;
    }
  }

  Future<http.Response> confirmSetupIntent(String paymentId, String setupIntentId) async {
    try {
      http.Response response = await http.post(Uri.parse("https://appollo-devops.web.app/confirmSetupIntent"),
          body: {"paymentId": paymentId, "setupIntentId": setupIntentId});
      return response;
    } on Exception catch (ex) {
      print(ex);
      return null;
    }
  }
}
