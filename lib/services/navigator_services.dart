import 'package:ticketapp/main.dart';

class NavigationService {
  static Future<dynamic> navigateTo(String routeName, {Object? arg, Map<String, String>? queryParams}) {
    if (queryParams != null) {
      routeName = Uri(path: routeName, queryParameters: queryParams).toString();
    }
    return WrapperPage.navigatorKey.currentState!.pushNamed(routeName, arguments: arg);
  }

  static dynamic goBack() {
    return WrapperPage.navigatorKey.currentState!.pop();
  }
}
