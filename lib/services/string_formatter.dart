import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StringFormatter {
  static String getDateTime(DateTime input, {bool showSeconds}) {
    try {
      String day = input.day < 10 ? "0" + input.day.toString() : input.day.toString();
      String month = input.month < 10 ? "0" + input.month.toString() : input.month.toString();
      String second = input.second < 10 ? "0" + input.second.toString() : input.second.toString();
      String minute = input.minute < 10 ? "0" + input.minute.toString() : input.minute.toString();
      String hour = input.hour < 10 ? "0" + input.hour.toString() : input.hour.toString();
      String dt = day + "/" + month + "/" + input.year.toString() + " " + hour + ":" + minute;
      if (showSeconds != false) {
        dt += ":" + second;
      }
      return dt;
    } catch (e) {
      return "";
    }
  }

  static String getDate(DateTime input) {
    try {
      String day = input.day < 10 ? "0" + input.day.toString() : input.day.toString();
      String month = input.month < 10 ? "0" + input.month.toString() : input.month.toString();
      return day + "/" + month + "/" + input.year.toString();
    } catch (e) {
      return "";
    }
  }

  static String getTime(DateTime input) {
    try {
      String second = input.second < 10 ? "0" + input.second.toString() : input.second.toString();
      String minute = input.minute < 10 ? "0" + input.minute.toString() : input.minute.toString();
      String hour = input.hour < 10 ? "0" + input.hour.toString() : input.hour.toString();
      return hour + ":" + minute + ":" + second;
    } catch (e) {
      return "";
    }
  }

  static String getTimeWithoutSeconds(DateTime input) {
    try {
      String minute = input.minute < 10 ? "0" + input.minute.toString() : input.minute.toString();
      String hour = input.hour < 10 ? "0" + input.hour.toString() : input.hour.toString();
      return hour + ":" + minute;
    } catch (e) {
      return "";
    }
  }

  /// Returns the timestamp as a string like: 'on day/month/year at hour/minute/second'
  static String getDateTimeString(Timestamp timestamp, {bool showSeconds = false}) {
    DateTime dt = DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);

    String day = dt.day < 10 ? "0" + dt.day.toString() : dt.day.toString();
    String month = dt.month < 10 ? "0" + dt.month.toString() : dt.month.toString();
    String second = dt.second < 10 ? "0" + dt.second.toString() : dt.second.toString();
    String minute = dt.minute < 10 ? "0" + dt.minute.toString() : dt.minute.toString();
    String hour = dt.hour < 10 ? "0" + dt.hour.toString() : dt.hour.toString();
    return "on " +
        day +
        "/" +
        month +
        "/" +
        dt.year.toString() +
        " at " +
        hour +
        ":" +
        minute +
        (showSeconds ? ":" + second : "");
  }

  static String getTimeWithoutSecondsFromTimestamp(Timestamp timestamp) {
    DateTime dt = DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);

    String minute = dt.minute < 10 ? "0" + dt.minute.toString() : dt.minute.toString();
    String hour = dt.hour < 10 ? "0" + dt.hour.toString() : dt.hour.toString();
    return hour + ":" + minute;
  }

  static String getDateFromTimestamp(Timestamp timestamp) {
    if (timestamp == null) {
      print("Timestamp was null");
      return "";
    }
    DateTime dt = DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);

    String day = dt.day < 10 ? "0" + dt.day.toString() : dt.day.toString();
    String month = dt.month < 10 ? "0" + dt.month.toString() : dt.month.toString();
    return day + "/" + month + "/" + dt.year.toString();
  }

// Has to be in format dd/mm/yyyy
  static DateTime getDateFromString(String date) {
    if (date.split("/").length != 3) {
      print("Invalid date format");
      return DateTime.now();
    }
    try {
      int day = int.parse(date.split("/")[0]);
      int month = int.parse(date.split("/")[1]);
      int year = int.parse(date.split("/")[2]);
      return DateTime(year, month, day);
    } catch (e) {
      print(e);
      return DateTime.now();
    }
  }

  static String buildDistanceString(String distance) {
    if (distance.length > 3) {
      distance = distance.substring(0, distance.length - 3) + "." + distance.substring(1, 3) + " km";
    } else {
      distance += " meters";
    }

    return distance;
  }

  static String buildRatingSubHeadline(num rating) {
    if (rating == null || rating == 0) {
      return "No rating yet";
    }
    String stars = "";
    for (int i = 0; i < rating.floor(); i++) {
      stars += "\u{2605}";
    }
    if (rating.remainder(rating.floor()) > 0.5) {
      stars += "\u{2605}";
    }

    String text;
    if (rating.floor() == rating.ceil()) {
      text = rating.toString() + ".0 ";
      text += stars;
      for (int i = rating.ceil(); i < 5; i++) {
        text += "\u{2606}";
      }
    } else if (rating.remainder(rating.floor()) > 0.5) {
      text = rating.toString() + " ";
      text += stars;
      for (int i = rating.ceil(); i < 5; i++) {
        text += "\u{2606}";
      }
    } else {
      text = rating.toString() + " ";
      text += stars;
      for (int i = rating.ceil(); i <= 5; i++) {
        text += "\u{2606}";
      }
    }

    return text;
  }

  static Widget formatOpeningHours(int day, String openingHours) {
    if (openingHours == null || openingHours == "") {
      openingHours = "-1";
    }
    String timeopen =
        openingHours == "-1" ? "Closed" : openingHours.substring(0, 2) + ":" + openingHours.substring(2, 4);
    String timeclose = openingHours == "-1" ? "" : openingHours.substring(4, 6) + ":" + openingHours.substring(6);

    String sday = "";

    switch (day) {
      case 0:
        sday = "Monday: ";
        break;
      case 1:
        sday = "Tuesday: ";
        break;
      case 2:
        sday = "Wednesday: ";
        break;
      case 3:
        sday = "Thursday: ";
        break;
      case 4:
        sday = "Friday: ";
        break;
      case 5:
        sday = "Saturday: ";
        break;
      case 6:
        sday = "Sunday: ";
        break;
    }

    return Row(
      children: <Widget>[
        Text(sday),
        Expanded(
          child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                timeopen == "Closed" ? timeopen : timeopen + " - " + timeclose,
              )),
        )
      ],
    );
  }

  static String getOpeningTime(int day, List<dynamic> openingHours) {
    String timeopen = openingHours[day] == "-1"
        ? "Closed"
        : openingHours[day].substring(0, 2) + ":" + openingHours[day].substring(2, 4);

    return timeopen;
  }

  static String getOpeningAndClosingTime(int day, List<dynamic> openingHours) {
    String timeopen = openingHours[day] == "-1"
        ? "Closed"
        : openingHours[day].substring(0, 2) +
            ":" +
            openingHours[day].substring(2, 4) +
            "-" +
            openingHours[day].substring(4, 6) +
            ":" +
            openingHours[day].substring(6);

    return timeopen;
  }

  static bool isBeforeTimeLimit(String limit) {
    if (limit == null || limit.length != 4) {
      return true;
    }
    int hour = int.parse(limit.substring(0, 2));
    int minute = int.parse(limit.substring(2));
    DateTime now = DateTime.now();

    // Would need proper time format to deal with change of day properly
    if (hour < 8 && now.hour > 8) {
      return true;
    } else if (now.hour < hour) {
      return true;
    } else if (now.hour == hour && now.minute < minute) {
      return true;
    } else
      return false;
  }

  static String capitaliseFirstLetter(String word) {
    return word.substring(0, 1).toUpperCase() + word.substring(1);
  }

  static String getWeekday(int day) {
    switch (day) {
      case 0:
        return "Monday";
        break;
      case 1:
        return "Tuesday";
        break;
      case 2:
        return "Wednesday";
        break;
      case 3:
        return "Thursday";
        break;
      case 4:
        return "Friday";
        break;
      case 5:
        return "Saturday";
        break;
      case 6:
        return "Sunday";
        break;
      default:
        return "Unknown";
    }
  }

  static String genderString(int gender) {
    switch (gender) {
      case 0:
        return "Female";
        break;
      case 1:
        return "Male";
        break;
      case 2:
        return "Other";
        break;
      default:
        return "Unknown gender";
        break;
    }
  }
}
