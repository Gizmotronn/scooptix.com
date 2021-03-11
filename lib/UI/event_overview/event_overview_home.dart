import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ticketapp/UI/event_overview/event_list.dart';
import 'package:ticketapp/UI/event_overview/event_overview_bottom_info.dart';
import 'package:ticketapp/UI/event_overview/event_overview_navbar.dart';
import 'package:ticketapp/UI/event_overview/featured_events.dart';
import 'package:ticketapp/UI/event_overview/side_buttons.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/model/event.dart';

class EventOverviewHome extends StatefulWidget {
  final List<Event> events;

  const EventOverviewHome({
    Key key,
    this.events,
  }) : super(key: key);

  @override
  _EventOverviewHomeState createState() => _EventOverviewHomeState();
}

class _EventOverviewHomeState extends State<EventOverviewHome> {
  List<Menu> _sideMenu = [
    Menu('Monday', true),
    Menu('Tuesday', false),
    Menu('Wednesday', false),
    Menu('Thursday', false),
    Menu('Friday', false),
    Menu('Saturday', false),
    Menu('Sunday', false),
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              child: Column(
                children: [
                  _eventOverview(screenSize),
                  _buildBody(),
                  EventOverviewBottomInfos(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Column _buildBody() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // _sideNav(screenSize),
            _buildEvents(),
          ],
        ),
      ],
    );
  }

  Widget _buildEvents() {
    return Column(
      children: [
        SizedBox(height: kToolbarHeight),
        AppolloEvents(events: widget.events),
      ],
    );
  }

  _eventOverview(Size screenSize) => Container(
        color: MyTheme.appolloBlack,
        width: screenSize.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FeaturedEvents(events: widget.events),
            EventOverviewNavigationBar()
          ],
        ),
      );

  _sideNav(Size screenSize) {
    return Wrap(
      children: [
        Container(
          height: screenSize.height,
          child: Container(
            child: Column(
              children: List.generate(
                _sideMenu.length,
                (index) => SideButton(
                  title: _sideMenu[index].title,
                  isTap: _sideMenu[index].isTap,
                  onTap: () {
                    setState(() {
                      for (var i = 0; i < _sideMenu.length; i++) {
                        _sideMenu[i].isTap = false;
                      }
                      _sideMenu[index].isTap = true;
                    });
                  },
                ).paddingAll(8),
              ),
            ),
          ),
        ),
      ],
    ).paddingTop(32);
  }
}

class Menu {
  String title;
  bool isTap;
  Menu(this.title, this.isTap);
}
