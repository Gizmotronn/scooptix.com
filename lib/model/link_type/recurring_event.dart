import 'link_type.dart';
import 'package:ticketapp/model/link_type/link_type.dart';

class RecurringEventLinkType extends LinkType {
  String? recurringEventId;

  static String toDBString() {
    return "recurring_event";
  }

  String get dbString => "recurring_event";
}
