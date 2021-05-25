import 'package:ticketapp/model/pre_sale/pre_sale_prize.dart';

/// Contains data about the pre sale conditions set up by the organizer.
class PreSale {
  bool enabled;
  DateTime registrationStartDate;
  DateTime registrationEndDate;
  List<PreSalePrize> prizes = [];

  PreSale({this.enabled, this.registrationStartDate, this.registrationEndDate});
}
