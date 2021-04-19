import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/model/link_type/link_type.dart';
import 'package:ticketapp/pages/authentication/authentication_page.dart';
import 'package:ticketapp/pages/error_page.dart';
import 'package:ticketapp/pages/event_details/event_detail_page.dart';
import 'package:ticketapp/pages/events_overview/events_overview_page.dart';
import 'package:ticketapp/pages/landing_page/landing_page.dart';
import '../../model/routing_data.dart';

class GeneratedRoute {
  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    final routeName = routeSettings.name;
    final arg = routeSettings.arguments;
    final routeData = routeSettings.name.getRouteData;

    switch (routeData.route) {
      case LandingPage.routeName:
        return _navigateTo(routeSettings, LandingPage());

      case EventOverviewPage.routeName:
        if (arg is List<Event>) {
          return _navigateTo(routeSettings, EventOverviewPage(events: arg));
        }
        return _navigateTo(routeSettings, EventOverviewPage(events: []));

      case AuthenticationPage.routeName:
        if (arg is LinkType) {
          return _navigateTo(routeSettings, AuthenticationPage(arg));
        }
        return _navigateTo(routeSettings, AuthenticationPage(null));

      case LandingPage.routeName:
        return _navigateTo(routeSettings, LandingPage());
      case EventDetailPage.routeName:
        final id = routeData['id'];
        if (id != null) {
          return _navigateTo(routeSettings, EventDetailPage(id: id));
        }
        return _navigateTo(routeSettings, ErrorPage('404: Page Not Found'));

      default:
        return _navigateTo(routeSettings, ErrorPage('404: Page Not Found'));
    }
  }
}

MaterialPageRoute _navigateTo(RouteSettings settings, Widget child) {
  return MaterialPageRoute(
    settings: settings,
    builder: (_) => child,
  );
}
