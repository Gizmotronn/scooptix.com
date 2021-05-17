import 'package:ticketapp/model/link_type/link_type.dart';

class AdvertisementLink extends LinkType {
  String organizerId;
  String advertisementId;

  @override
  String toString() {
    return "advertisement";
  }
}
