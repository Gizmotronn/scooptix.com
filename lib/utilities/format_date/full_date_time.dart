import 'package:intl/intl.dart';

String fullDateWithDay(DateTime dateTime) => DateFormat("EEEE, MMMM d'th' - hh:mm aa").format(dateTime);
String fullDate(DateTime dateTime) => DateFormat("MMMM d'th' - hh:mm aa").format(dateTime);
String fullDateWithYear(DateTime dateTime) => DateFormat("EEEE, MMMM d'th' yyyy hh:mm aa").format(dateTime);
String date(DateTime dateTime) => DateFormat("EEEE, MMMM d'th' yyyy").format(dateTime);
String time(DateTime dateTime) => DateFormat("hh:mm aa").format(dateTime);
String money(double money) =>
    NumberFormat.simpleCurrency(name: 'USD', locale: "en_US", decimalDigits: 00).format(money);
