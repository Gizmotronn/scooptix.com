import 'package:ticketapp/model/link_type/link_type.dart';
import 'package:ticketapp/model/promoter.dart';

abstract class Invitation extends LinkType {
  Promoter promoter;
}
