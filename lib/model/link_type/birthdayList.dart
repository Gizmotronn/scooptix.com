import 'package:ticketapp/model/link_type/invitation.dart';

class Booking extends Invitation {
  static String toDBString() {
    return "booking";
  }
}
