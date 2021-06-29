import 'invitation.dart';

class PreSaleInvite extends Invitation {
  static String toDBString() {
    return "pre_sale_invite";
  }

  String get dbString => "pre_sale_invite";
}
