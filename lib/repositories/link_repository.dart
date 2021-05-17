import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ticketapp/model/link_type/advertisementInvite.dart';
import 'package:ticketapp/model/link_type/birthdayList.dart';
import 'package:ticketapp/model/link_type/link_type.dart';
import 'package:ticketapp/model/link_type/memberInvite.dart';
import 'package:ticketapp/model/link_type/overview.dart';
import 'package:ticketapp/repositories/events_repository.dart';
import 'package:ticketapp/repositories/user_repository.dart';

class LinkRepository {
  static LinkRepository _instance;

  static LinkRepository get instance {
    if (_instance == null) {
      _instance = LinkRepository._();
    }
    return _instance;
  }

  LinkRepository._();

  dispose() {
    _instance = null;
  }

  LinkType linkType = OverviewLinkType();

  Future<LinkType> loadLinkType(String uuid) async {
    try {
      QuerySnapshot uuidMapSnapshot =
          await FirebaseFirestore.instance.collection("uuidmap").where("uuid", isEqualTo: uuid).get();
      if (uuidMapSnapshot.size > 0) {
        LinkTypes lt = LinkTypes.MemberInvite;
        try {
          lt = LinkTypes.values.firstWhere((element) => element.toDBString() == uuidMapSnapshot.docs[0].data()["type"]);
        } catch (_) {
          linkType = OverviewLinkType();
          return linkType;
        }
        switch (lt) {
          case LinkTypes.BirthdayList:
          case LinkTypes.Booking:
            linkType = Booking()
              ..uuid = uuid
              ..promoter = await UserRepository.instance.loadPromoter(uuidMapSnapshot.docs[0].data()["promoter"])
              ..event = await EventsRepository.instance.loadEventById(uuidMapSnapshot.docs[0].data()["event"]);
            break;
          case LinkTypes.Advertisement:
            linkType = AdvertisementLink()
              ..uuid = uuid
              ..advertisementId = uuidMapSnapshot.docs[0].data()["advertisement_id"]
              ..event = await EventsRepository.instance.loadEventById(uuidMapSnapshot.docs[0].data()["event"]);
            break;
          case LinkTypes.MemberInvite:
            linkType = MemberInvite()
              ..uuid = uuid
              ..promoter = await UserRepository.instance.loadPromoter(uuidMapSnapshot.docs[0].data()["promoter"])
              ..event = await EventsRepository.instance.loadEventById(uuidMapSnapshot.docs[0].data()["event"]);
            break;
        }
        return linkType;
      } else {
        return null;
      }
    } catch (e, s) {
      print(e);
      // BugsnagNotifier.instance.notify(e, s, severity: ErrorSeverity.error);
      return null;
    }
  }
}
