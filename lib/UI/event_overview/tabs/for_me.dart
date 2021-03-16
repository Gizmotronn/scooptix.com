import 'package:flutter/material.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/buttons/apollo_button.dart';
import 'package:ticketapp/UI/widgets/cards/forme_card.dart';
import 'package:ticketapp/utilities/svg/icon.dart';

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
