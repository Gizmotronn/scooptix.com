import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:ticketapp/UI/widgets/cards/event_card.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/buttons/apollo_button.dart';
import 'package:ticketapp/model/event.dart';

class AppolloEvents extends StatelessWidget {
  final List<Event> events;

  const AppolloEvents({Key key, this.events}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      width: screenSize.width * 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: MyTheme.appolloWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _eventTags(context, tag: '', count: '12 Events'),
                Wrap(
                  spacing: 0,
                  runSpacing: 0,
                  children: List.generate(events.length, (index) {
                    return EventCard(
                      event: events[index],
                    );
                  }),
                ).paddingAll(6),
              ],
            ),
          ),
          HoverAppolloButton(
            title: 'See More Events',
            color: MyTheme.appolloGrey,
            hoverColor: MyTheme.appolloGreen,
            fill: false,
          ).paddingAll(32),
        ],
      ),
    );
  }

  Widget _eventTags(context, {String tag, String count}) => Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutoSizeText(''),
            AutoSizeText(count ?? '',
                style: Theme.of(context)
                    .textTheme
                    .headline3
                    .copyWith(color: MyTheme.appolloGrey)),
          ],
        ),
      ).paddingHorizontal(16).paddingTop(16);
}
