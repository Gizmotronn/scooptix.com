import 'package:ticketapp/model/event.dart';

enum LinkTypes { Booking, BirthdayList, Advertisement, MemberInvite }

extension InvitationTypeExtension on LinkTypes {
  String toDBString() {
    return this.toString().split(".")[1].toLowerCase();
  }

  String toDisplayString() {
    if (this == LinkTypes.BirthdayList) {
      return "Birthday List";
    } else {
      return this.toString().split(".")[1];
    }
  }
}

abstract class LinkType {
  Event event;
  String uuid;
}
