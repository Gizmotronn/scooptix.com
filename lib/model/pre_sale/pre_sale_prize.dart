import 'package:ticketapp/model/pre_sale/pre_sale.dart';

import '../discount.dart';

abstract class PreSalePrize {
  int rank;
  PreSaleType type;

  PreSalePrize(this.rank, this.type);

  String prizeDescription() {
    return "";
  }
}

class PreSaleTicketPrize extends PreSalePrize {
  String managerDocID;
  int quantity;

  PreSaleTicketPrize({required this.managerDocID, required this.quantity, required rank, required type})
      : super(rank, type);

  static const String dbTypeName = "tickets";

  @override
  String prizeDescription() {
    return "$quantity free Tickets";
  }
}

class PreSaleDiscountPrize extends PreSalePrize {
  DiscountType discountType;
  double discountValue;

  PreSaleDiscountPrize({required this.discountType, required this.discountValue, required rank, required type})
      : super(rank, type);

  static const String dbTypeName = "discount";

  @override
  String prizeDescription() {
    if (discountType == DiscountType.percent) {
      return "$discountValue% discount";
    } else {
      return "\$${discountValue / 100} discount";
    }
  }
}

class PreSaleCustomPrize extends PreSalePrize {
  String prize;
  String description;

  PreSaleCustomPrize({required this.prize, required this.description, required rank, required type})
      : super(rank, type);

  static const String dbTypeName = "custom";

  @override
  String prizeDescription() {
    return "$prize";
  }
}
