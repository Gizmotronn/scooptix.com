import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/venue.dart';
import 'package:ticketapp/model/venue.dart';

class VenuesRepository {
  static VenuesRepository? _instance;

  static VenuesRepository get instance {
    if (_instance == null) {
      _instance = VenuesRepository._();
    }
    return _instance!;
  }

  VenuesRepository._();

  dispose() {
    _instance = null;
  }

  List<Venue> venues = <Venue>[];

  Future<Venue?> loadVenueById(String id) async {
    Venue venue;
    try {
      // Check if venue is loaded already
      venue = venues.firstWhere((element) => element.docID == id);
    } catch (_) {
      // If not load from DB
      DocumentSnapshot<Map<String, dynamic>> venueSnapshot =
          await FirebaseFirestore.instance.collection("venues").doc(id).get();
      if (venueSnapshot.exists) {
        try {
          venue = Venue.fromMap(id, venueSnapshot.data()!);
          venues.add(venue);
          return venue;
        } catch (_) {}
      }
    }
    return null;
  }
}
