import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:ticketapp/UI/widgets/cards/no_events.dart';
import 'package:ticketapp/UI/widgets/cards/appollo_bg_card.dart';
import 'package:ticketapp/model/event.dart';

import '../../theme.dart';
import '../events.dart';

class AllEvents extends StatelessWidget {
  final List<Event> events;
  final AutoSizeText headline;

  const AllEvents({Key key, this.events, this.headline}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    if (events.isEmpty) {
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppolloBackgroundCard(
            child: Column(
              children: [
                _eventTags(context),
                AppolloEvents(events: events),
              ],
            ),
          ).paddingBottom(16),
        ],
      ),
    );
  }

  Widget _eventTags(context) => Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            headline,
            AutoSizeText("${events.length.toString()} Events",
                style: Theme.of(context)
                    .textTheme
                    .headline4
                    .copyWith(color: MyTheme.appolloWhite, fontWeight: FontWeight.w500)),
          ],
        ),
      ).paddingHorizontal(16).paddingTop(16);
}
