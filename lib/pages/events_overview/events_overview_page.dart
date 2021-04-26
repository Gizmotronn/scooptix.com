import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ticketapp/UI/event_overview/event_overview_home.dart';
import 'package:ticketapp/UI/event_overview/event_top_nav.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/pages/authentication/bloc/authentication_bloc.dart';
import 'package:ticketapp/pages/event_details/desktop_view_drawer.dart';
import 'package:ticketapp/pages/events_overview/bloc/events_overview_bloc.dart';

class EventOverviewPage extends StatefulWidget {
  static const String routeName = '/events';

  final List<Event> events;
  const EventOverviewPage({Key key, this.events}) : super(key: key);

  @override
  _EventOverviewPageState createState() => _EventOverviewPageState();
}

class _EventOverviewPageState extends State<EventOverviewPage> {
  AuthenticationBloc signUpBloc;
  EventsOverviewBloc bloc = EventsOverviewBloc();
  var scaffoldState = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    signUpBloc = AuthenticationBloc();

    super.initState();
  }

  @override
  void dispose() {
    bloc.close();

    signUpBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      key: scaffoldState,
      endDrawer: BlocProvider.value(
          value: signUpBloc,
          child: DesktopViewDrawer(
            bloc: signUpBloc,
            linkType: null,
          )),
      endDrawerEnableOpenDragGesture: false,
      backgroundColor: MyTheme.appolloWhite,
      body: BlocProvider(
        create: (_) => bloc,
        child: Container(
          color: MyTheme.appolloBackgroundColor,
          width: screenSize.width,
          height: screenSize.height,
          child: Stack(
            children: [
              BlocProvider.value(
                value: signUpBloc,
                child: EventOverviewHome(bloc: bloc, authBloc: signUpBloc, events: widget.events),
              ),

              /// TODO More Events page with fliters and map
              // MoreEventsFliterMapPage(events: events),
              Scaffold.of(context).hasEndDrawer ? BlurBackground() : SizedBox(),
              EventOverviewAppbar(bloc: signUpBloc),
            ],
          ),
        ),
      ),
    );
  }
}

class BlurBackground extends StatefulWidget {
  const BlurBackground({
    Key key,
  }) : super(key: key);

  @override
  _BlurBackgroundState createState() => _BlurBackgroundState();
}

class _BlurBackgroundState extends State<BlurBackground> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 16,
        sigmaY: 16,
      ),
      child: Container(
        color: Colors.transparent,
        width: screenSize.width,
        height: screenSize.height,
      ),
    );
  }
}
