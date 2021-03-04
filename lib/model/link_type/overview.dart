import 'package:ticketapp/model/link_type/link_type.dart';

import '../event.dart';

class OverviewLinkType extends LinkType {
  OverviewLinkType(Event event) {
    this.event = event;
  }
}
