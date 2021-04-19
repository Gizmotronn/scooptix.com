import '../event.dart';
import 'link_type.dart';
import 'package:ticketapp/model/link_type/link_type.dart';

class OverviewLinkType extends LinkType {
  OverviewLinkType(Event event) {
    this.event = event;
  }
}
