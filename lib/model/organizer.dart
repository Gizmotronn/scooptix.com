class Organizer {
  String? firstName;
  String? lastName;
  String? description;
  String coverImage = "";
  String organizationName = "";

  Organizer._();

  String getFullName() {
    if (firstName != null && lastName != null) {
      return firstName! + " " + lastName!;
    } else {
      return "";
    }
  }

  factory Organizer.fromMap(String id, Map<String, dynamic> data) {
    Organizer organizer = Organizer._();

    if (data.containsKey("firstname")) {
      organizer.firstName = data["firstname"];
    }
    if (data.containsKey("lastname")) {
      organizer.lastName = data["lastname"];
    }
    if (data.containsKey("coverimage")) {
      organizer.coverImage = data["coverimage"];
    }
    if (data.containsKey("description")) {
      organizer.description = data["description"];
    }
    if (data.containsKey("name")) {
      organizer.organizationName = data["name"];
    }

    return organizer;
  }
}
