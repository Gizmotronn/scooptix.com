import 'dart:html';
import 'package:flutter/material.dart';
import 'package:ticketapp/UI/widgets/appollo/appollo_progress_indicator.dart';
import 'package:ticketapp/model/link_type/advertisementInvite.dart';
import 'package:ticketapp/model/link_type/link_type.dart';
import 'package:ticketapp/model/link_type/memberInvite.dart';
import 'package:ticketapp/pages/event_details/event_detail_page.dart';
import 'package:ticketapp/pages/events_overview/events_overview_page.dart';
import 'package:ticketapp/repositories/events_repository.dart';
import 'package:ticketapp/repositories/link_repository.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/services/navigator_services.dart';

class LandingPage extends StatefulWidget {
  static const String routeName = '/landing';

  const LandingPage({Key key}) : super(key: key);

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    final uri = Uri.parse(window.location.href);
    String uuid = ""; // Use this for normal functionality
    // String uuid = "jAPHBX"; // Takes you to a test event

    if (uri.queryParameters.containsKey("id")) {
      uuid = uri.queryParameters["id"];
    }

    // If an event link was used, load this event and forward the user to the event details page.
    LinkRepository.instance.loadLinkType(uuid).then((value) {
      if (value == null) {
        _preloadEventsAndNavigate();
      } else {
        _manageLinkType(value);
      }
    });

    super.initState();
  }

  _preloadEventsAndNavigate() async {
    final events = await EventsRepository.instance.loadUpcomingEvents();
    NavigationService.navigateTo(EventOverviewPage.routeName, arg: events);
  }

  _manageLinkType(LinkType link) async {
    final events = await EventsRepository.instance.loadUpcomingEvents();
    if (link is MemberInvite) {
      NavigationService.navigateTo(EventDetailPage.routeName, queryParams: {"id": link.event.docID});
    } else if (link is AdvertisementLink) {
      NavigationService.navigateTo(EventDetailPage.routeName, queryParams: {"id": link.event.docID});
    } else {
      NavigationService.navigateTo(EventOverviewPage.routeName, arg: events);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: AppolloProgressIndicator().paddingBottom(8),
    );
  }
}
