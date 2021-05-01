enum DiscountType { value, percent }

class Discount {
  String docId;
  int amount;
  DiscountType type;
  int maxUses;
  int timesUsed;
  String code;

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
        return null;
      }

      discount.maxUses = data["max_uses"];
      discount.timesUsed = data["times_used"];
      discount.code = data["code"];

      return discount;
    } catch (_) {
      return null;
    }
  }
}
