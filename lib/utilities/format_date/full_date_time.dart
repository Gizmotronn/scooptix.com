import 'package:intl/intl.dart';

String fullDate(DateTime dateTime) => DateFormat("EEEE, MMMM d'th' - hh:mm aa")?.format(dateTime);

String time(DateTime dateTime) => DateFormat("hh:mm aa")?.format(dateTime);
String money(int money) => NumberFormat.simpleCurrency(name: 'USD', locale: "en_US", decimalDigits: 00).format(money);
