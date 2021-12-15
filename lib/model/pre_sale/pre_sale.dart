import 'dart:math';

import 'package:ticketapp/model/pre_sale/pre_sale_prize.dart';

enum PreSaleType { ranked, raffle }

extension PreSaleTypeExtension on PreSaleType {
  String toDBString() {
    return this.toString().split(".")[1].toLowerCase();
  }

  String toDisplayString() {
    if (this == PreSaleType.ranked) {
      return "Leaderboard Competition";
    } else {
      return "Prize Draw";
    }
  }
}

/// Contains data about the pre sale conditions set up by the organizer.
class PreSale {
  bool enabled;
  DateTime registrationStartDate;
  DateTime registrationEndDate;
  List<PreSaleTicketPrize> ticketPrizes = [];
  List<PreSaleDiscountPrize> discountPrizes = [];
  List<PreSaleCustomPrize> customPrizes = [];

  PreSale({required this.enabled, required this.registrationStartDate, required this.registrationEndDate});

  bool get hasPrizes => ticketPrizes.isNotEmpty || discountPrizes.isNotEmpty || customPrizes.isNotEmpty;
  int get numPrizes => max(max(ticketPrizes.length, discountPrizes.length), customPrizes.length);
  List<PreSalePrize> get activePrizes => ticketPrizes.isNotEmpty
      ? ticketPrizes
      : discountPrizes.isNotEmpty
          ? discountPrizes
          : customPrizes.isNotEmpty
              ? customPrizes
              : [];
}
