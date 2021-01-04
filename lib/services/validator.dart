// Validates textfield input
class Validator {
  static String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Please enter a valid email address';
    else
      return null;
  }

  static String validateAge(String value) {
    if (value.length < 1 || value.split("/").length != 3) {
      return "Please provide your age (you have to be 18 or older to sign up)";
    } else {
      int day = int.parse(value.split("/")[0]);
      int month = int.parse(value.split("/")[1]);
      int year = int.parse(value.split("/")[2]);
      if (DateTime.now().difference(DateTime(year, month, day)).inDays < 18 * 365.25) {
        return "You have to be at least 18 years old to sign up";
      } else {
        return null;
      }
    }
  }

  static String validateAgeWithPreviousValue(String value, String prev) {
    if (value.length < 1 && prev != null && prev.length != 0) {
      return "Please provide your age";
    } else {
      return null;
    }
  }

  static String validatePassword(String value) {
    if (value.length < 8) {
      return "Password must be at least 8 characters long";
    } else {
      return null;
    }
  }

  static String validatePasswordRepeat(String value, String password) {
    if (value != password) {
      return "Your passwords don't match!";
    } else {
      return null;
    }
  }

  static String validateName(String value) {
    if (value.length < 1) {
      return "Please provide a name";
    } else {
      return null;
    }
  }
}
