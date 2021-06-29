import 'package:ticketapp/model/link_type/link_type.dart';

class AdvertisementLink extends LinkType {
  String organizerId;
  String advertisementId;

  static String toDBString() {
    return "advertisement";
  }

  String get dbString => "advertisement";
}
