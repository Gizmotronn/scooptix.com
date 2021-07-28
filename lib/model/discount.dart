enum DiscountType { value, percent }

class Discount {
  late String docId;
  late int amount;
  late DiscountType type;
  late int maxUses;
  late int timesUsed;
  late String code;
  late List<String> appliesToReleases = [];

  Discount._();

  bool enoughLeft(int quantity) {
    return maxUses >= timesUsed + quantity;
  }

  factory Discount.fromMap(String id, Map<String, dynamic> data) {
    Discount discount = Discount._();

    try {
      discount.docId = id;

      if (data.containsKey("discount_percent")) {
        discount.type = DiscountType.percent;
        discount.amount = data["discount_percent"];
      } else if (data.containsKey("discount_value")) {
        discount.type = DiscountType.value;
        discount.amount = data["discount_value"];
      } else {
        throw Exception("Couldn't load Discount, no type given");
      }

      discount.maxUses = data["max_uses"];
      discount.timesUsed = data["times_used"];
      discount.code = data["code"];

      if (data.containsKey("applies_to")) {
        discount.appliesToReleases = (data["applies_to"] as List<dynamic>).cast<String>().toList();
      }

      return discount;
    } catch (e) {
      print(e);
      throw Exception("Couldn't load Discount");
    }
  }
}
