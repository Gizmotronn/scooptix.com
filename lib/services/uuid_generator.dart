import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class UUIDGenerator {
  static Future<String> createNewUUID() async {
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
}
