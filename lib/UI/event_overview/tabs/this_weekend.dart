import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:ticketapp/UI/event_overview/events.dart';
import 'package:ticketapp/UI/event_overview/side_buttons.dart';
import 'package:ticketapp/UI/widgets/buttons/apollo_button.dart';
import 'package:ticketapp/UI/widgets/cards/no_events.dart';
import 'package:ticketapp/UI/widgets/cards/appollo_bg_card.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/utilities/format_date/full_date_time.dart';

import '../../theme.dart';
import '../event_overview_home.dart';

class ThisWeekend extends StatefulWidget {
  final List<Event> events;
  final ScrollController scrollController;

  const ThisWeekend({Key key, this.events, this.scrollController}) : super(key: key);

  @override
  _ThisWeekendState createState() => _ThisWeekendState();
}

class _ThisWeekendState extends State<ThisWeekend> {
  List<Menu> _weekendMenu = [];

  List<double> positions = [];

  @override
  void initState() {
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 5));
    _weekendMenu = List.generate(3, (index) => index)
        .map(
          (value) => Menu(
              "${DateFormat(DateFormat.WEEKDAY, 'en_US').format(firstDayOfWeek.add(Duration(days: value)))}",
              DateFormat(DateFormat.DAY, 'en_US')
                  .format(firstDayOfWeek.add(Duration(days: value)))
                  .contains(DateFormat(DateFormat.DAY, 'en_US').format(DateTime.now())),
              id: value,
              subtitle: ' ${DateFormat(DateFormat.DAY, 'en_US').format(firstDayOfWeek.add(Duration(days: value)))}',
              fullDate: ' ${DateFormat('d MMM y', 'en_US').format(firstDayOfWeek.add(Duration(days: value)))}'),
        )
        .toList();
    _weekendMenu.forEach((_) {
      positions.add(0.0);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    if (widget.events.isEmpty) {
      return NoEvents();
    }

    return Container(
      width: getValueForScreenType(
          context: context,
          desktop: screenSize.width * 0.8,
          tablet: screenSize.width * 0.8,
          mobile: screenSize.width,
          watch: screenSize.width),
      child: Column(
        children: [
          _weekendNav().paddingBottom(16),
          Column(
            children: List.generate(
              _weekendMenu.length,
              (index) => Builder(
                builder: (context) {
                  if (widget.events
                      .where((event) => fullDateWithDay(event.date).contains(_weekendMenu[index].title))
                      .toList()
                      .isEmpty) {
                    return SizedBox();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      BoxOffset(
                        boxOffset: (offset) {
                          setState(() {
                            positions[_weekendMenu[index].id] = offset.dy;
                          });
                        },
                        child: AppolloBackgroundCard(
                          child: Column(
                            children: [
                              _eventTags(context,
                                  tag1: "${_weekendMenu[index].title}'s Events",
                                  tag2: ' | ${_weekendMenu[index].fullDate}'),
                              AppolloEvents(
                                  events: widget.events
                                      .where((event) => fullDateWithDay(event.date).contains(_weekendMenu[index].title))
                                      .toList()),
                              HoverAppolloButton(
                                title: 'See More Events',
                                color: MyTheme.appolloGreen,
                                hoverColor: MyTheme.appolloGreen,
                                fill: false,
                              ).paddingBottom(16),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: kToolbarHeight),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _weekendNav() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: List.generate(
            _weekendMenu.length,
            (index) => SideButton(
              title: "${_weekendMenu[index].title} ${_weekendMenu[index].subtitle}",
              isTap: _weekendMenu[index].isTap,
              onTap: widget.events
                      .where((event) => fullDateWithDay(event.date).contains(_weekendMenu[index].title))
                      .toList()
                      .isEmpty
                  ? null
                  : () {
                      setState(() {
                        for (var i = 0; i < _weekendMenu.length; i++) {
                          _weekendMenu[i].isTap = false;
                        }
                        _weekendMenu[index].isTap = true;
                      });

                      widget.scrollController
                          .animateTo(positions[index], curve: Curves.linear, duration: Duration(milliseconds: 300));
                    },
            ),
          ),
        ),
      ],
    ).paddingTop(8);
  }

  Widget _eventTags(context, {String tag1, String tag2}) => Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutoSizeText.rich(
                TextSpan(
                  text: tag1 ?? '',
                  children: [
                    if (getValueForScreenType<bool>(
                      context: context,
                      mobile: false,
                      watch: false,
                      desktop: true,
                      tablet: true,
                    ))
                      TextSpan(
                        text: " $tag2" ?? '',
                        style: Theme.of(context)
                            .textTheme
                            .headline4
                            .copyWith(color: MyTheme.appolloRed, fontWeight: FontWeight.w500),
                      ),
                  ],
                ),
                style: Theme.of(context).textTheme.headline4.copyWith(fontWeight: FontWeight.w500)),
          ],
        ),
      ).paddingHorizontal(16).paddingTop(8);
}
