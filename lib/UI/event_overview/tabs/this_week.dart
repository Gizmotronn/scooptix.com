import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:ticketapp/UI/event_overview/events.dart';
import 'package:ticketapp/UI/event_overview/side_buttons.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/buttons/apollo_button.dart';
import 'package:ticketapp/UI/widgets/cards/white_card.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/utilities/format_date/full_date_time.dart';

import '../event_overview_home.dart';

class ThisWeek extends StatefulWidget {
  final List<Event> events;

  const ThisWeek({Key key, this.events}) : super(key: key);

  @override
  _ThisWeekState createState() => _ThisWeekState();
}

class _ThisWeekState extends State<ThisWeek> {
  List<Menu> _daysMenu = [
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
                      .where((event) =>
                          fullDate(event.date).contains(_daysMenu[index].title))
                      .toList()
                      .isEmpty) {
                    return SizedBox();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      WhiteCardWithNoElevation(
                        child: Column(
                          children: [
                            _eventTags(context,
                                tag: "${_daysMenu[index].title}'s Event"),
                            AppolloEvents(
                              events: widget.events
                                  .where((event) => fullDate(event.date)
                                      .contains(_daysMenu[index].title))
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

  Widget _eventTags(context, {String tag}) => Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutoSizeText(tag ?? '',
                style: Theme.of(context)
                    .textTheme
                    .headline3
                    .copyWith(color: MyTheme.appolloGrey)),
          ],
        ),
      ).paddingHorizontal(16).paddingTop(16);

  Widget _daysNav() {
    return WhiteCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
    );
  }
}
