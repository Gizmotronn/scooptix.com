import 'package:ticketapp/services/bugsnag_wrapper.dart';

/// Stores data displayed on the event details page
/// Allows organizers to display custom data such as sponsors
class CustomEventInfo {
  String headline;
  List<String> targetUrls = [];
  List<String> imageUrls = [];

  CustomEventInfo._();

  factory CustomEventInfo.fromMap(Map<String, dynamic> data) {
    try {
      CustomEventInfo eventInfo = CustomEventInfo._();

      eventInfo.headline = data["headline"];
      eventInfo.imageUrls = data["image_urls"].cast<String>().toList();
      eventInfo.targetUrls = data["target_urls"].cast<String>().toList();

      print(eventInfo.imageUrls);
      print(eventInfo.targetUrls);
      return eventInfo;
    } catch (e, s) {
      print(e);
      print(s);
      BugsnagNotifier.instance.notify("Error loading Custom Event Info $data $e", s);
      return null;
    }
  }
}
