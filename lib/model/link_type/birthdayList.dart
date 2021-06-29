import 'package:ticketapp/model/link_type/invitation.dart';

class Booking extends Invitation {
  @override
  static String toDBString() {
    return "booking";
  }

  String get dbString => "booking";
}
