class Promoter {
  String docId;
  String firstName;
  String lastName;

  Promoter._();

  factory Promoter.fromMap(String id, Map<String, dynamic> data) {
    Promoter promoter = Promoter._();

    promoter.docId = id;

    if (data.containsKey("firstname")) {
      promoter.firstName = data["firstname"];
    }
    if (data.containsKey("lastname")) {
      promoter.lastName = data["lastname"];
    }

    return promoter;
  }
}
