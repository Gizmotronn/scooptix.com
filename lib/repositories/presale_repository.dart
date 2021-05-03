import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/repositories/user_repository.dart';
import 'package:ticketapp/model/user.dart';

class PreSaleRepository {
  static PreSaleRepository _instance;

  static PreSaleRepository get instance {
    if (_instance == null) {
      _instance = PreSaleRepository._();
    }
    return _instance;
  }

  PreSaleRepository._();

  dispose() {
    _instance = null;
  }

  Map<Event, bool> _registered = {};

  Future<bool> isRegisteredForPreSale(Event event) async {
    if (_registered.containsKey(event)) {
      return _registered[event];
    } else {
      _registered[event] = (await FirebaseFirestore.instance
              .collection("ticketevents")
              .doc(event.docID)
              .collection("presale_registrations")
              .doc(UserRepository.instance.currentUser().firebaseUserID)
              .get())
          .exists;
      return _registered[event];
    }
  }

  Future<void> registerForPreSale(Event event) async {
    if (!await isRegisteredForPreSale(event)) {
      await FirebaseFirestore.instance
          .collection("ticketevents")
          .doc(event.docID)
          .collection("presale_registrations")
          .doc(UserRepository.instance.currentUser().firebaseUserID)
          .set({
        "date": DateTime.now(),
        "firstName": UserRepository.instance.currentUser().firstname,
        "lastName": UserRepository.instance.currentUser().lastname,
        "email": UserRepository.instance.currentUser().email,
        "gender": UserRepository.instance.currentUser().gender.toDBString(),
        "dob": UserRepository.instance.currentUser().dob
      });
    }
  }
}
