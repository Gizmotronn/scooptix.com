import 'link_type.dart';
import 'package:ticketapp/model/link_type/link_type.dart';

class OverviewLinkType extends LinkType {
  OverviewLinkType();

  static String toDBString() {
    return "overview";
  }
}
