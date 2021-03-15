import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ticketapp/UI/event_overview/event_list.dart';
import 'package:ticketapp/UI/event_overview/event_overview_bottom_info.dart';
import 'package:ticketapp/UI/event_overview/event_overview_navbar.dart';
import 'package:ticketapp/UI/event_overview/featured_events.dart';
import 'package:ticketapp/UI/event_overview/side_buttons.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/cards/white_card.dart';
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
  List<Menu> _daysMenu = [
    Menu('Monday', true),
    Menu('Tuesday', false),
    Menu('Wednesday', false),
    Menu('Thursday', false),
    Menu('Friday', false),
    Menu('Saturday', false),
    Menu('Sunday', false),
  ];

  List<Menu> _weekendMenu = [
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
                  _buildBody(screenSize),
                  EventOverviewFooter(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(screenSize) {
    return Column(
      children: [
        _buildEvents(screenSize),
      ],
    );
  }

  Widget _buildEvents(screenSize) {
    return Column(
      children: [
        SizedBox(height: kToolbarHeight),

        ///Weekdays tabs
        // _daysNav(screenSize),
        // _weekendNav(screenSize),
        EventsForMe(),
        AppolloEvents(events: widget.events),
        SizedBox(height: kToolbarHeight),
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

  Widget _daysNav(Size screenSize) {
    return SizedBox(
      width: screenSize.width * 0.8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          WhiteCard(
            child: Row(
              children: List.generate(
                _daysMenu.length,
                (index) => SideButton(
                  title: _daysMenu[index].title,
                  isTap: _daysMenu[index].isTap,
                  onTap: () {
                    setState(() {
                      for (var i = 0; i < _daysMenu.length; i++) {
                        _daysMenu[i].isTap = false;
                      }
                      _daysMenu[index].isTap = true;
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _weekendNav(Size screenSize) {
    return SizedBox(
      width: screenSize.width * 0.8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          WhiteCard(
            child: Row(
              children: List.generate(
                _weekendMenu.length,
                (index) => SideButton(
                  title: _weekendMenu[index].title,
                  isTap: _weekendMenu[index].isTap,
                  onTap: () {
                    setState(() {
                      for (var i = 0; i < _weekendMenu.length; i++) {
                        _weekendMenu[i].isTap = false;
                      }
                      _weekendMenu[index].isTap = true;
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    ).paddingTop(8);
  }
}

class Menu {
  String title;
  bool isTap;
  Menu(this.title, this.isTap);
}
