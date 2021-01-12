import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webapp/model/link_type/advertisementInvite.dart';
import 'package:webapp/model/link_type/birthdayList.dart';
import 'package:webapp/model/link_type/invitation.dart';
import 'package:webapp/model/link_type/link_type.dart';
import 'package:webapp/model/user.dart';
import 'package:webapp/repositories/user_repository.dart';

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
          .doc(UserRepository.instance.currentUser.firebaseUserID);
      await userRef.set({
        "firstname": UserRepository.instance.currentUser.firstname,
        "lastname": UserRepository.instance.currentUser.lastname,
        "gender": UserRepository.instance.currentUser.gender.toDBString(),
        "dob": UserRepository.instance.currentUser.dob,
        "email": UserRepository.instance.currentUser.email,
        "last_action": DateTime.now()
      });

      return userRef;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> addCustomerAttendingAction(LinkType linkType) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection("organizers")
          .doc(linkType.event.organizer)
          .collection("customers")
          .doc(UserRepository.instance.currentUser.firebaseUserID)
          .get();
      DocumentReference userRef;
      if (!userSnapshot.exists) {
        userRef = await createCustomer(linkType.event.organizer);
      } else {
        userRef = userSnapshot.reference;
      }

      String action;

      if (linkType is BirthdayList) {
        action = "bday_invite_accepted";
      } else if (linkType is AdvertisementInvite) {
        action = "advertisement_invite_accepted";
      } else {
        action = "promoter_invite_accepted";
      }

      userRef
          .collection("actions")
          .add({"event": linkType.event.docID, "date": DateTime.now(), "action": action, "uuid": linkType.uuid});

      userRef.set({
        "last_action": DateTime.now(),
        "events": FieldValue.arrayUnion([linkType.event.docID])
      }, SetOptions(merge: true));
    } catch (e) {
      print(e);
    }
  }
}
