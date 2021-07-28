abstract class PreSalePrize {
  String? name;
  List<String> prizes = [];
}

class PreSaleRankedPrize extends PreSalePrize {
  int? rank;
}

class PreSaleRafflePrize extends PreSalePrize {}
