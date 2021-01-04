class Organizer {
  String firstName;
  String lastName;
  String description;
  String coverImage = "";

  Organizer._();

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

    return organizer;
  }
}
