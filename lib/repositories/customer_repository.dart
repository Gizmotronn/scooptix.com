import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webapp/model/link_type/advertisementInvite.dart';
import 'package:webapp/model/link_type/birthdayList.dart';
import 'package:webapp/model/link_type/invitation.dart';
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

  Future<void> addCustomerAttendingAction(Invitation invitation) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection("organizers")
          .doc(invitation.event.organizer)
          .collection("customers")
          .doc(UserRepository.instance.currentUser.firebaseUserID)
          .get();
      DocumentReference userRef;
      if (!userSnapshot.exists) {
        userRef = await createCustomer(invitation.event.organizer);
      } else {
        userRef = userSnapshot.reference;
      }

      String action;

      if (invitation is BirthdayList) {
        action = "bday_invite_accepted";
      } else if (invitation is AdvertisementInvite) {
        action = "advertisement_invite_accepted";
      } else {
        action = "promoter_invite_accepted";
      }

      userRef
          .collection("actions")
          .add({"event": invitation.event.docID, "date": DateTime.now(), "action": action, "uuid": invitation.uuid});
    } catch (e) {
      print(e);
    }
  }
}
