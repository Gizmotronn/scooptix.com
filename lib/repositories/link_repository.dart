import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ticketapp/model/birthday_lists/birthdaylist.dart';
import 'package:ticketapp/model/link_type/advertisementInvite.dart';
import 'package:ticketapp/model/link_type/birthdayList.dart';
import 'package:ticketapp/model/link_type/link_type.dart';
import 'package:ticketapp/model/link_type/memberInvite.dart';
import 'package:ticketapp/model/link_type/overview.dart';
import 'package:ticketapp/model/link_type/pre_sale_invite.dart';
import 'package:ticketapp/model/link_type/recurring_event.dart';
import 'package:ticketapp/repositories/events_repository.dart';
import 'package:ticketapp/repositories/user_repository.dart';

class LinkRepository {
  static LinkRepository? _instance;

  static LinkRepository get instance {
    if (_instance == null) {
      _instance = LinkRepository._();
    }
    return _instance!;
  }

  LinkRepository._();

  dispose() {
    _instance = null;
  }

  LinkType linkType = OverviewLinkType();

  Future<LinkType?> loadLinkType(String uuid) async {
    try {
      QuerySnapshot uuidMapSnapshot =
          await FirebaseFirestore.instance.collection("uuidmap").where("uuid", isEqualTo: uuid).get();
      if (uuidMapSnapshot.size > 0) {
        String type = uuidMapSnapshot.docs[0].get("type");
        //TODO: remove birthdaylist once port to bookings is finished
        if (type == BirthdayList.toDBString() || type == Booking.toDBString() || type == "birthdaylist") {
          linkType = Booking()
            ..uuid = uuid
            ..promoter = await UserRepository.instance.loadPromoter(uuidMapSnapshot.docs[0].get("promoter"))
            ..event = await EventsRepository.instance.loadEventById(uuidMapSnapshot.docs[0].get("event"));
        } else if (type == AdvertisementLink.toDBString()) {
          linkType = AdvertisementLink()
            ..uuid = uuid
            ..advertisementId = uuidMapSnapshot.docs[0].get("advertisement_id")
            ..event = await EventsRepository.instance.loadEventById(uuidMapSnapshot.docs[0].get("event"));
        } else if (type == MemberInvite.toDBString()) {
          linkType = MemberInvite()
            ..uuid = uuid
            ..promoter = await UserRepository.instance.loadPromoter(uuidMapSnapshot.docs[0].get("promoter"))
            ..event = await EventsRepository.instance.loadEventById(uuidMapSnapshot.docs[0].get("event"));
        } else if (type == PreSaleInvite.toDBString()) {
          linkType = PreSaleInvite()
            ..uuid = uuid
            ..promoter = await UserRepository.instance.loadPromoter(uuidMapSnapshot.docs[0].get("promoter"))
            ..event = await EventsRepository.instance.loadEventById(uuidMapSnapshot.docs[0].get("event"));
        } else if (type == RecurringEventLinkType.toDBString()) {
          linkType = RecurringEventLinkType()
            ..uuid = uuid
            ..recurringEventId = uuidMapSnapshot.docs[0].get("recurring_event_id")
            ..event = await EventsRepository.instance
                .loadNextRecurringEvent(uuidMapSnapshot.docs[0].get("recurring_event_id"));
        }
      }
      return linkType;
    } catch (e) {
      print(e);
      // BugsnagNotifier.instance.notify(e, s, severity: ErrorSeverity.error);
      return null;
    }
  }
}
