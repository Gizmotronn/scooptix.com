import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ticketapp/model/birthday_lists/birthdaylist.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/repositories/user_repository.dart';

enum BirthdayListStatus { Pending, Declined, Accepted }

extension BirthdayListStatusExtension on BirthdayListStatus {
  String getDBString() {
    return this.toString().split(".")[1].toLowerCase();
  }

  String getDisplayString() {
    return this.toString().split(".")[1];
  }
}

enum PassType { PriorityPass, QPass, CheckIn, Invitation, Barchella, Birthdaylist }

extension PassTypeExtension on PassType {
  String toDisplayString() {
    return this.toString().split(".")[1];
  }

  String toDBString() {
    return this.toString().split(".")[1].toLowerCase();
  }
}

class BirthdayListRepository {
  static BirthdayListRepository _instance;

  static BirthdayListRepository get instance {
    if (_instance == null) {
      _instance = BirthdayListRepository._();
    }
    return _instance;
  }

  BirthdayListRepository._();

  dispose() {
    _instance = null;
  }

  Future<String> createOrLoadUUIDMap(Event event, String creatorId, String message, int numGuests) async {
    QuerySnapshot uuidSnapshot = await FirebaseFirestore.instance
        .collection("uuidmap")
        .where("event", isEqualTo: event.docID)
        .where("promoter", isEqualTo: creatorId)
        .where("type", isEqualTo: "birthdaylist")
        .get();
    if (uuidSnapshot.docs.length != 0) {
      return uuidSnapshot.docs[0].data()["uuid"];
    } else {
      String uuid = await createNewUUID();
      await FirebaseFirestore.instance.collection("uuidmap").add({
        'uuid': uuid,
        'type': "birthdaylist",
        'event': event.docID,
        'eventdate': event.date,
        'promoter': creatorId,
        'message': message,
        "num_guests": numGuests,
        'status': BirthdayListStatus.Pending.getDBString()
      });
      return uuid;
    }
  }

  Future<String> createNewUUID() async {
    const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();
    bool uuidFound = false;
    while (!uuidFound) {
      String uuid = String.fromCharCodes(Iterable.generate(6, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
      QuerySnapshot uuidmapSnapshot =
          await FirebaseFirestore.instance.collection("uuidmap").where("uuid", isEqualTo: uuid).get();
      if (uuidmapSnapshot.size == 0) {
        uuidFound = true;
        return uuid;
      }
    }
    return "";
  }

  Future<BirthdayList> loadExistingList(String eventId) async {
    QuerySnapshot listSnapshot = await FirebaseFirestore.instance
        .collection("uuidmap")
        .where("event", isEqualTo: eventId)
        .where("promoter", isEqualTo: UserRepository.instance.currentUser().firebaseUserID)
        .where("type", isEqualTo: "birthdaylist")
        .get();

    if (listSnapshot.size == 0) {
      return null;
    } else {
      return BirthdayList()..uuid = listSnapshot.docs[0].data()["uuid"];
    }
  }
}
