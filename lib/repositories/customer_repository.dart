import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/model/link_type/advertisementInvite.dart';
import 'package:ticketapp/model/link_type/birthdayList.dart';
import 'package:ticketapp/model/link_type/memberInvite.dart';
import 'package:ticketapp/model/user.dart';
import 'package:ticketapp/repositories/link_repository.dart';
import 'package:ticketapp/repositories/user_repository.dart';
import 'package:ticketapp/services/bugsnag_wrapper.dart';

class CustomerRepository {
  static CustomerRepository? _instance;

  static CustomerRepository get instance {
    if (_instance == null) {
      _instance = CustomerRepository._();
    }
    return _instance!;
  }

  CustomerRepository._();

  dispose() {
    _instance = null;
  }

  Future<DocumentReference?> createCustomer(Event event) async {
    try {
      DocumentReference userRef = FirebaseFirestore.instance
          .collection("organizers")
          .doc(event.organizer)
          .collection("customers")
          .doc(UserRepository.instance.currentUser()!.firebaseUserID);
      await userRef.set({
        "firstname": UserRepository.instance.currentUser()!.firstname,
        "lastname": UserRepository.instance.currentUser()!.lastname,
        "gender": UserRepository.instance.currentUser()!.gender!.toDBString(),
        "dob": UserRepository.instance.currentUser()!.dob,
        "email": UserRepository.instance.currentUser()!.email,
        "last_action": DateTime.now(),
        "first_action": DateTime.now(),
        "first_event": event.docID
      });

      return userRef;
    } catch (e, s) {
      print(e);
      BugsnagNotifier.instance.notify("Error creating customer \n $e", s, severity: ErrorSeverity.error);
      return null;
    }
  }

  /// Adds an action based on the Link Type to an existing customer or creates a new customer if it's the users first interaction with this organizer.
  Future<void> addCustomerAttendingAction(Event event) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection("organizers")
          .doc(event.organizer)
          .collection("customers")
          .doc(UserRepository.instance.currentUser()!.firebaseUserID)
          .get();
      DocumentReference? userRef;
      if (!userSnapshot.exists) {
        userRef = await createCustomer(event);
      } else {
        userRef = userSnapshot.reference;
      }

      String action;

      if (LinkRepository.instance.linkType is Booking) {
        action = "booking_invite_accepted";
      } else if (LinkRepository.instance.linkType is AdvertisementLink) {
        action = "advertisement_invite_accepted";
      } else if (LinkRepository.instance.linkType is MemberInvite) {
        action = "member_invite_accepted";
      } else {
        action = "ticket_bought";
      }

      userRef!.collection("actions").add({
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
      BugsnagNotifier.instance.notify("Error adding customer action \n $e", s, severity: ErrorSeverity.error);
    }
  }
}
