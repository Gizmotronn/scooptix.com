import 'dart:io';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ticketapp/UI/event_overview/event_list.dart';
import 'package:ticketapp/UI/event_overview/event_overview_bottom_info.dart';
import 'package:ticketapp/UI/event_overview/event_overview_navbar.dart';
import 'package:ticketapp/UI/event_overview/featured_events.dart';
import 'package:ticketapp/UI/event_overview/side_buttons.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/cards/event_card.dart';
import 'package:ticketapp/UI/widgets/cards/white_card.dart';
import 'package:ticketapp/UI/widgets/icons/svgicon.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/utilities/svg/icon.dart';

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
                  // _eventOverview(screenSize),
                  // _buildBody(screenSize),
                  MoreEventsFliterMap(events: widget.events),
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
        _daysNav(screenSize),
        _weekendNav(screenSize),
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

class MoreEventsFliterMap extends StatelessWidget {
  const MoreEventsFliterMap({
    Key key,
    this.events,
  }) : super(key: key);
  final List<Event> events;
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Column(
      children: [
        SizedBox(height: kToolbarHeight + 20),
        Container(
          width: screenSize.width,
          color: MyTheme.appolloWhite,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFliters(),
              _buildEvents(),
              _buildMap(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFliters() => SizedBox(
        width: 300,
        child: EventSearchFliter(),
      );

  Widget _buildEvents() => SizedBox(
        child: Stack(
          children: [
            Column(
              children: List.generate(events.length, (index) {
                return EventCard2(
                  event: events[index],
                );
              }),
            ),
          ],
        ),
      );

  Widget _buildMap() => SizedBox();
}

class EventSearchFliter extends StatelessWidget {
  const EventSearchFliter({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AutoSizeText(
          'Fliters',
          style: Theme.of(context)
              .textTheme
              .caption
              .copyWith(fontSize: 16, color: MyTheme.appolloGrey),
        ).paddingBottom(16),
        _buildLocation(context),
        _buildPriceRange(context),
        _buildDateRange(context),
        _buildEventType(context),
        _buildEventCategory(context),
      ],
    ).paddingAll(16);
  }

  Widget _buildLocation(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _textFieldTitle(context, 'Location'),
        FliterTextField(
          title: 'Perth, Australie',
          prefixIcon: SvgIcon(
            AppolloSvgIcon.perthGps,
            size: 16,
            color: MyTheme.appolloGrey,
          ),
        ).paddingBottom(16),
      ],
    );
  }

  Widget _buildDateRange(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _textFieldTitle(context, 'Date Range'),
        Row(
          children: [
            Expanded(
                child: FliterTextField(
              title: 'From',
              suffixIcon: SvgIcon(
                AppolloSvgIcon.calenderOutline,
                size: 16,
                color: MyTheme.appolloGrey,
              ),
            ).paddingRight(8)),
            Expanded(
                child: FliterTextField(
                    title: 'To',
                    suffixIcon: SvgIcon(
                      AppolloSvgIcon.calenderOutline,
                      size: 16,
                      color: MyTheme.appolloGrey,
                    )).paddingLeft(8)),
          ],
        ).paddingBottom(16),
      ],
    );
  }

  Widget _buildPriceRange(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _textFieldTitle(context, 'Price Range'),
        Row(
          children: [
            Expanded(
                child: FliterTextField(title: 'From(\$)').paddingRight(18)),
            Container(height: 1.1, width: 5, color: MyTheme.appolloGrey),
            Expanded(child: FliterTextField(title: 'To(\$)').paddingLeft(18)),
          ],
        ).paddingBottom(16),
      ],
    );
  }

  Widget _textFieldTitle(BuildContext context, String title) {
    return AutoSizeText(title,
            style: Theme.of(context).textTheme.caption.copyWith(
                color: MyTheme.appolloBlack, fontWeight: FontWeight.w500))
        .paddingBottom(12);
  }

  Widget _buildEventType(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _textFieldTitle(context, 'Type'),
          Container(
            height: 40,
            decoration: BoxDecoration(
                color: MyTheme.appolloGrey.withAlpha(40),
                borderRadius: BorderRadius.circular(4)),
            child: DropdownButton(
              isExpanded: true,
              hint: AutoSizeText('Select',
                  style: Theme.of(context)
                      .textTheme
                      .caption
                      .copyWith(color: MyTheme.appolloGrey, fontSize: 14)),
              onChanged: (v) {},
              items: [
                DropdownMenuItem(child: Text('Type'), value: 'Type'),
              ],
              underline: Container(),
            ).paddingHorizontal(8),
          )
        ],
      ).paddingBottom(16);

  Widget _buildEventCategory(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _textFieldTitle(context, 'Category'),
          Container(
            height: 40,
            decoration: BoxDecoration(
                color: MyTheme.appolloGrey.withAlpha(40),
                borderRadius: BorderRadius.circular(4)),
            child: DropdownButton(
              isExpanded: true,
              hint: AutoSizeText('Select',
                  style: Theme.of(context)
                      .textTheme
                      .caption
                      .copyWith(color: MyTheme.appolloGrey, fontSize: 14)),
              onChanged: (v) {},
              items: [
                DropdownMenuItem(child: Text('Category1'), value: 'Category1'),
              ],
              underline: Container(),
            ).paddingHorizontal(8),
          )
        ],
      );
}

class FliterTextField extends StatelessWidget {
  final String title;

  final prefixIcon;

  final suffixIcon;

  const FliterTextField({Key key, this.title, this.prefixIcon, this.suffixIcon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TextField(
        decoration: InputDecoration(
          fillColor: MyTheme.appolloGrey.withAlpha(40),
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(
              width: 0,
              style: BorderStyle.none,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(
              width: 0,
              style: BorderStyle.none,
            ),
          ),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          hintText: title,
          hintStyle: Theme.of(context)
              .textTheme
              .caption
              .copyWith(color: MyTheme.appolloGrey, fontSize: 14),
        ),
      ),
    );
  }
}
