import 'invitation.dart';

class MemberInvite extends Invitation {
  static String toDBString() {
    return "memberinvite";
  }

  String get dbString => "memberinvite";
}
