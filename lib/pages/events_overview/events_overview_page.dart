import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:ticketapp/UI/event_overview/event_overview_home.dart';
import 'package:ticketapp/UI/event_overview/event_top_nav.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/pages/app_bar.dart';
import 'package:ticketapp/pages/events_overview/bloc/events_overview_bloc.dart';

class EventOverviewPage extends StatefulWidget {
  static const String routeName = '/events';

  final List<Event> events;
  const EventOverviewPage({Key key, this.events}) : super(key: key);

  @override
  _EventOverviewPageState createState() => _EventOverviewPageState();
}

class _EventOverviewPageState extends State<EventOverviewPage> {
  EventsOverviewBloc bloc = EventsOverviewBloc();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: ResponsiveBuilder(builder: (context, size) {
        if (size.isDesktop || size.isTablet) {
          return Scaffold(
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
                      value: bloc,
                      child: EventOverviewHome(bloc: bloc, events: widget.events),
                    ),

                    /// TODO More Events page with fliters and map
                    // MoreEventsFliterMapPage(events: events),
                    EventOverviewAppbar(),
                  ],
                ),
              ),
            ),
          );
        } else {
          return SafeArea(
            child: Scaffold(
              extendBodyBehindAppBar: true,
              backgroundColor: MyTheme.appolloWhite,
              appBar: AppolloAppBar(),
              body: BlocProvider(
                create: (_) => bloc,
                child: Container(
                  color: MyTheme.appolloBackgroundColor,
                  width: screenSize.width,
                  height: screenSize.height,
                  child: Stack(
                    children: [
                      BlocProvider.value(
                        value: bloc,
                        child: EventOverviewHome(bloc: bloc, events: widget.events),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      }),
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
