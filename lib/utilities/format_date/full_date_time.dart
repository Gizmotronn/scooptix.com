import 'package:intl/intl.dart';

String fullDate(DateTime dateTime) =>
    DateFormat("EEEE, MMMM d'th' - hh:mm aa").format(dateTime);
