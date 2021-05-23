import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/model/link_type/pre_sale_invite.dart';
import 'package:ticketapp/model/pre_sale/pre_sale_registration.dart';
import 'package:ticketapp/repositories/events_repository.dart';
import 'package:ticketapp/repositories/link_repository.dart';
import 'package:ticketapp/repositories/user_repository.dart';
import 'package:ticketapp/model/user.dart';
import 'package:ticketapp/services/uuid_generator.dart';

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

  Map<Event, PreSaleRegistration> _registered = {};

  Future<PreSaleRegistration> isRegisteredForPreSale(Event event) async {
    if (_registered.containsKey(event)) {
      return _registered[event];
    } else {
      QuerySnapshot mapSnapshot = await FirebaseFirestore.instance
          .collection("uuidmap")
          .where("promoter", isEqualTo: UserRepository.instance.currentUser().firebaseUserID)
          .where("type", isEqualTo: PreSaleInvite.toDBString())
          .where("event", isEqualTo: event.docID)
          .limit(1)
          .get();
      if (mapSnapshot.size > 0) {
        _registered[event] = PreSaleRegistration()
          ..docId = UserRepository.instance.currentUser().firebaseUserID
          ..points = mapSnapshot.docs[0].data()["points"]
          ..uuid = mapSnapshot.docs[0].data()["uuid"];
        return _registered[event];
      } else {
        return null;
      }
    }
  }

  Future<PreSaleRegistration> registerForPreSale(Event event) async {
    PreSaleRegistration preSale = await isRegisteredForPreSale(event);
    if (preSale == null) {
      String uuid = await UUIDGenerator.createNewUUID();
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
        "dob": UserRepository.instance.currentUser().dob,
        "uuid": uuid,
        if (LinkRepository.instance.linkType is PreSaleInvite)
          "referred_by": (LinkRepository.instance.linkType as PreSaleInvite).promoter.docId
      });
      print("ticket");

      await FirebaseFirestore.instance.collection("uuidmap").add({
        "uuid": uuid,
        "type": PreSaleInvite.toDBString(),
        "event": event.docID,
        "eventdate": event.date,
        "presale_end": event.preSale.registrationEndDate,
        "date": DateTime.now(),
        "promoter": UserRepository.instance.currentUser().firebaseUserID,
        "points": 1,
      });
      preSale = PreSaleRegistration()
        ..uuid = uuid
        ..docId = UserRepository.instance.currentUser().firebaseUserID
        ..points = 1;
      print("map");
      return preSale;
    } else {
      return preSale;
    }
  }

  Future<List<PreSaleRegistration>> loadPreSaleRegistrations(String userId) async {
    QuerySnapshot mapSnapshot = await FirebaseFirestore.instance
        .collection("uuidmap")
        .where("promoter", isEqualTo: userId)
        .where("type", isEqualTo: PreSaleInvite.toDBString())
        .where("eventdate", isGreaterThan: DateTime.now())
        .get();

    List<PreSaleRegistration> preSales = [];

    await Future.forEach(mapSnapshot.docs, (doc) async {
      preSales.add(PreSaleRegistration()
        ..docId = doc.id
        ..uuid = doc.data()["uuid"]
        ..points = doc.data()["points"]
        ..event = await EventsRepository.instance.loadEventById(doc.data()["event"]));
    });

    return preSales;
  }
}
