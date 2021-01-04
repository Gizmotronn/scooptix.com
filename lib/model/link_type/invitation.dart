import 'package:webapp/model/link_type/link_type.dart';
import 'package:webapp/model/promoter.dart';

abstract class Invitation extends LinkType {
  Promoter promoter;
}
