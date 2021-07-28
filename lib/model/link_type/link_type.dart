import 'package:ticketapp/model/event.dart';

abstract class LinkType {
  Event? event;
  String? uuid;

  static String toDBString() {
    return "";
  }

  String get dbString => "";
}
