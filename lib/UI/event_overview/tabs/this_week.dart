import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ticketapp/UI/event_overview/events.dart';
import 'package:ticketapp/UI/event_overview/side_buttons.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/buttons/apollo_button.dart';
import 'package:ticketapp/UI/widgets/cards/no_events.dart';
import 'package:ticketapp/UI/widgets/cards/appollo_bg_card.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/utilities/format_date/full_date_time.dart';

import '../event_overview_home.dart';

class ThisWeek extends StatefulWidget {
  final List<Event> events;
  final ScrollController scrollController;

  const ThisWeek({Key key, this.events, this.scrollController}) : super(key: key);

  @override
  _ThisWeekState createState() => _ThisWeekState();
}

class _ThisWeekState extends State<ThisWeek> {
  List<Menu> _daysMenu = [];
  List<double> positions = [];

  @override
  void initState() {
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    _daysMenu = List.generate(7, (index) => index)
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

    _daysMenu.forEach((_) {
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
      width: screenSize.width * 0.8,
      child: Column(
        children: [
          _daysNav().paddingBottom(16),
          Column(
            children: List.generate(
              _daysMenu.length,
              (index) => Builder(
                builder: (context) {
                  if (widget.events
                      .where((event) => fullDate(event.date).contains(_daysMenu[index].title))
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
                            positions[_daysMenu[index].id] = offset.dy;
                          });
                        },
                        child: AppolloBackgroundCard(
                          child: Column(
                            children: [
                              _eventTags(context,
                                  tag1: "${_daysMenu[index].title}'s Events |", tag2: " ${_daysMenu[index].fullDate}"),
                              AppolloEvents(
                                events: widget.events
                                    .where((event) => fullDate(event.date).contains(_daysMenu[index].title))
                                    .toList(),
                              ),
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

  Widget _eventTags(context, {String tag1, String tag2}) => Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutoSizeText.rich(
                TextSpan(
                  text: tag1 ?? '',
                  children: [
                    TextSpan(
                      text: " $tag2" ?? '',
                      style: Theme.of(context).textTheme.headline3.copyWith(color: MyTheme.appolloRed),
                    ),
                  ],
                ),
                style: Theme.of(context).textTheme.headline3.copyWith(color: MyTheme.appolloWhite)),
          ],
        ),
      ).paddingHorizontal(16).paddingTop(16);

  Widget _daysNav() {
    return AppolloCard(
      color: MyTheme.appolloCardColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          _daysMenu.length,
          (index) => SideButton(
            title: "${_daysMenu[index].title} ${_daysMenu[index].subtitle}",
            isTap: _daysMenu[index].isTap,
            onTap:
                widget.events.where((event) => fullDate(event.date).contains(_daysMenu[index].title)).toList().isEmpty
                    ? null
                    : () async {
                        setState(() {
                          for (var i = 0; i < _daysMenu.length; i++) {
                            _daysMenu[i].isTap = false;
                          }
                          _daysMenu[index].isTap = true;
                        });
                        await widget.scrollController
                            .animateTo(positions[index], curve: Curves.linear, duration: Duration(milliseconds: 300));
                      },
          ),
        ),
      ),
    );
  }
}