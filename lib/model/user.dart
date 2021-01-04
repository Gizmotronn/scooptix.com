class User {
  String firebaseUserID = "";
  String firstname;
  String lastname;
  String email;
  bool receiveEmails;
  DateTime dob;
  String phone;
  int gender;
  Map<String, dynamic> userSettings = Map<String, dynamic>();
  List<String> favourites = List<String>();
  String role;
  String profileImageURL = "";

  String getFullName() {
    if (firstname != null) {
      return firstname + " " + lastname;
    } else {
      return "";
    }
  }

  toggleFavourite(String docID) {
    favourites.contains(docID) ? favourites.remove(docID) : favourites.add(docID);
    favourites.contains(docID);
  }

  clear() {
    firebaseUserID = "";
    firstname = "";
    lastname = "";
    email = "";
    dob = DateTime.now();
    phone = "";
    role = "";
    gender = -1;
  }
}
