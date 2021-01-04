import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webapp/model/venue.dart';

class VenuesRepository {
  static VenuesRepository _instance;

  static VenuesRepository get instance {
    if (_instance == null) {
      _instance = VenuesRepository._();
    }
    return _instance;
  }

  VenuesRepository._();

  dispose() {
    _instance = null;
  }

  List<Venue> venues = List<Venue>();

  Future<Venue> loadVenueById(String id) async {
    Venue venue;
    try {
      // Check if venue is loaded already
      venue = venues.firstWhere((element) => element.docID == id);
    } catch (_) {
      // If not load from DB
      DocumentSnapshot venueSnapshot = await FirebaseFirestore.instance.collection("venues").doc(id).get();
      if (venueSnapshot.exists) {
        venue = Venue.fromMap(id, venueSnapshot.data());
      }
      if (venue != null) {
        venues.add(venue);
      }
    }
    return venue;
  }
}
