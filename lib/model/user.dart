enum Gender { Female, Male, Other, Unknown }

extension GenderExtension on Gender {
  String toDBString() {
    return this.toString().split(".")[1].toLowerCase();
  }

  String toDisplayString() {
    return this.toString().split(".")[1];
  }
}

class User {
  String firebaseUserID = "";
  String firstname;
  String lastname;
  String email;
  bool receiveEmails;
  DateTime dob;
  String phone;
  Gender gender;
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
    gender = Gender.Unknown;
  }
}
