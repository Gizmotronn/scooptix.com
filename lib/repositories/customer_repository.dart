import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/model/link_type/advertisementInvite.dart';
import 'package:ticketapp/model/link_type/birthdayList.dart';
import 'package:ticketapp/model/user.dart';
import 'package:ticketapp/repositories/link_repository.dart';
import 'package:ticketapp/repositories/user_repository.dart';
import 'package:ticketapp/services/bugsnag_wrapper.dart';

class CustomerRepository {
  static CustomerRepository _instance;

  static CustomerRepository get instance {
    if (_instance == null) {
      _instance = CustomerRepository._();
    }
    return _instance;
  }

  CustomerRepository._();

  dispose() {
    _instance = null;
  }

  Future<DocumentReference> createCustomer(String organizerId) async {
    try {
      DocumentReference userRef = FirebaseFirestore.instance
          .collection("organizers")
          .doc(organizerId)
          .collection("customers")
          .doc(UserRepository.instance.currentUser().firebaseUserID);
      await userRef.set({
        "firstname": UserRepository.instance.currentUser().firstname,
        "lastname": UserRepository.instance.currentUser().lastname,
        "gender": UserRepository.instance.currentUser().gender.toDBString(),
        "dob": UserRepository.instance.currentUser().dob,
        "email": UserRepository.instance.currentUser().email,
        "last_action": DateTime.now()
      });

      return userRef;
    } catch (e, s) {
      print(e);
      BugsnagNotifier.instance.notify(e, s, severity: ErrorSeverity.error);
      return null;
    }
  }

  Future<void> addCustomerAttendingAction(Event event) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection("organizers")
          .doc(event.organizer)
          .collection("customers")
          .doc(UserRepository.instance.currentUser().firebaseUserID)
          .get();
      DocumentReference userRef;
      if (!userSnapshot.exists) {
        userRef = await createCustomer(event.organizer);
      } else {
        userRef = userSnapshot.reference;
      }

      String action;

      if (event is Booking) {
        action = "bday_invite_accepted";
      } else if (event is AdvertisementLink) {
        action = "advertisement_invite_accepted";
      } else {
        action = "promoter_invite_accepted";
      }

      userRef.collection("actions").add({
        "event": event.docID,
        "date": DateTime.now(),
        "action": action,
        "uuid": LinkRepository.instance.linkType.uuid
      });

      userRef.set({
        "last_action": DateTime.now(),
        "events": FieldValue.arrayUnion([event.docID])
      }, SetOptions(merge: true));
    } catch (e, s) {
      print(e);
      BugsnagNotifier.instance.notify(e, s, severity: ErrorSeverity.error);
    }
  }
}
