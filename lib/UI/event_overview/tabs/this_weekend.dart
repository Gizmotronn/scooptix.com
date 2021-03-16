import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:ticketapp/UI/event_overview/events.dart';
import 'package:ticketapp/UI/event_overview/side_buttons.dart';
import 'package:ticketapp/UI/widgets/cards/white_card.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/utilities/format_date/full_date_time.dart';

import '../../theme.dart';
import '../event_overview_home.dart';

class ThisWeekend extends StatefulWidget {
  final List<Event> events;

  const ThisWeekend({Key key, this.events}) : super(key: key);

  @override
  _ThisWeekendState createState() => _ThisWeekendState();
}

class _ThisWeekendState extends State<ThisWeekend> {
  List<Menu> _weekendMenu = [
    Menu('Friday', true),
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
          _weekendNav().paddingBottom(16),
          Column(
            children: List.generate(
              _weekendMenu.length,
              (index) => Builder(
                builder: (context) {
                  if (widget.events
                      .where((event) => fullDate(event.date)
                          .contains(_weekendMenu[index].title))
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
                                tag: "${_weekendMenu[index].title}'s Event"),
                            AppolloEvents(
                                events: widget.events
                                    .where((event) => fullDate(event.date)
                                        .contains(_weekendMenu[index].title))
                                    .toList()),
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

  Widget _weekendNav() {
    return Row(
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
    ).paddingTop(8);
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
}
