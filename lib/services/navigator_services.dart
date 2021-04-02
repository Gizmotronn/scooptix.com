import 'package:flutter/cupertino.dart';

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Future<dynamic> navigateTo(String routeName, {Object arg, Map<String, String> queryParams}) {
    if (queryParams != null) {
      routeName = Uri(path: routeName, queryParameters: queryParams).toString();
    }
    return navigatorKey.currentState.pushNamed(routeName, arguments: arg);
  }

  static dynamic goBack() {
    return navigatorKey.currentState.pop();
  }
}
