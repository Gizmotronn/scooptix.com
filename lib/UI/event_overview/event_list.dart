import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:ticketapp/UI/widgets/cards/event_card.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/buttons/apollo_button.dart';
import 'package:ticketapp/UI/widgets/icons/svgicon.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/utilities/svg/icon.dart';

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
          const SizedBox(height: kToolbarHeight),
          HoverAppolloButton(
            title: 'See More Events',
            color: MyTheme.appolloGreen,
            hoverColor: MyTheme.appolloGreen,
            fill: false,
          ),
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

class EventsForMe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Container(
      height: screenSize.height * 0.5,
      width: screenSize.width * 0.8,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                ForMeCard(
                  title: 'Curated Events',
                  color: MyTheme.appolloGreen,
                  subTitle:
                      'We find events your might be interested in based on your preferences. Making it easier then ever to find something to do.',
                  svgIcon: AppolloSvgIcon.calender,
                ),
                ForMeCard(
                  title: 'Follow your favourite organisers',
                  subTitle:
                      'Be the first to see new events from your favourite organisers, simply follow them and we will keep you up to date.',
                  color: MyTheme.appolloOrange,
                  svgIcon: AppolloSvgIcon.people,
                ),
                ForMeCard(
                  title: 'Like an event',
                  subTitle:
                      'Liked events will be shown here. Its the easiest way to get back to an event your are interested in.',
                  color: MyTheme.appolloRed,
                  svgIcon: AppolloSvgIcon.heart,
                ),
              ],
            ),
          ),
          ForMeCard(
            title:
                'Create an acount and discover the best event based on your preferences',
            subTitle:
                'Keep up to date with the latest events from your favourite organisers and find new events based on your preferences when you sign in.',
            svgIcon: AppolloSvgIcon.person,
            color: MyTheme.appolloPurple,
            child: HoverAppolloButton(
              title: 'Sign In',
              color: MyTheme.appolloPurple,
              hoverColor: MyTheme.appolloPurple,
              maxHeight: 30,
              minHeight: 25,
              maxWidth: 120,
              minWidth: 100,
              fill: false,
            ).paddingTop(4),
          ),
        ],
      ),
    );
  }
}

class ForMeCard extends StatelessWidget {
  final String title;
  final String subTitle;
  final Color color;
  final String svgIcon;

  final Widget child;
  const ForMeCard({
    Key key,
    @required this.title,
    @required this.subTitle,
    this.color,
    @required this.svgIcon,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: MyTheme.appolloGrey.withAlpha(15),
              spreadRadius: 3,
              blurRadius: 3,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgIcon(svgIcon, size: 50).paddingBottom(8),
            Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  AutoSizeText(
                    title,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        .copyWith(color: color, fontWeight: FontWeight.w400),
                  ).paddingBottom(8),
                  AutoSizeText(
                    subTitle,
                    maxLines: 4,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(color: MyTheme.appolloGrey, fontSize: 10),
                  ).paddingBottom(8),
                  Container(
                    child: child ?? Container(),
                  )
                ],
              ),
            ),
          ],
        ).paddingAll(8),
      ).paddingAll(8),
    );
  }
}
