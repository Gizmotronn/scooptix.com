import 'package:ticketapp/model/link_type/link_type.dart';

class AdvertisementInvite extends LinkType {
  String organizerId;
  String advertisementId;

  @override
  String toString() {
    return "advertisement_invitation";
  }
}
