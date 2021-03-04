import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:ticketapp/UI/widgets/apollo_button.dart';

import '../theme.dart';

class EventCard extends StatelessWidget {
  final String eventTitle;
  final String eventAddress;
  final String eventTime;
  final String eventImageUrl;
  final Function onTapViewEvent;
  final Function onTapGetEventTicket;

  const EventCard({
    Key key,
    @required this.eventTitle,
    @required this.eventAddress,
    @required this.eventTime,
    @required this.onTapViewEvent,
    @required this.onTapGetEventTicket,
    @required this.eventImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 60.0, sigmaY: 60.0),
      child: ResponsiveBuilder(builder: (context, SizingInformation sizes) {
        return Container(
          width: sizes.isDesktop ? 600 : 450,
          decoration: BoxDecoration(
              color: MyTheme.appolloWhite,
              border: Border.all(width: 0.5, color: MyTheme.appolloGrey),
              borderRadius: BorderRadius.circular(12)),
          child: Center(
            child: AspectRatio(
              aspectRatio: 1.9,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _cardContent(context),
                  _cardImage(),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _cardContent(context) {
    return Flexible(
      flex: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            color: MyTheme.appolloWhite,
            border: Border.all(width: 0.5, color: MyTheme.appolloGrey),
          ),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AutoSizeText(
                  eventTitle ?? '',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.headline2.copyWith(
                      color: MyTheme.appolloPurple, letterSpacing: 1.5),
                ).paddingBottom(8),
                Icon(Icons.place, color: MyTheme.appolloPurple)
                    .paddingBottom(4),
                AutoSizeText(
                  eventAddress ?? '',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: Theme.of(context)
                      .textTheme
                      .headline5
                      .copyWith(color: MyTheme.appolloGrey),
                ).paddingBottom(4),
                AutoSizeText(
                  eventTime ?? '',
                  textAlign: TextAlign.center,
                  // maxLines: 2,
                  group: AutoSizeGroup(),
                  style: Theme.of(context)
                      .textTheme
                      .headline3
                      .copyWith(color: MyTheme.appolloGrey),
                ).paddingBottom(16),
                AppolloButton.smallButton(
                    color: Colors.transparent,
                    child: AutoSizeText('View Event',
                        style: Theme.of(context)
                            .textTheme
                            .button
                            .copyWith(color: MyTheme.appolloPurple)),
                    onTap: () {}),
                Container(
                        child: AppolloButton.smallButton(
                            child: AutoSizeText(
                              'Get Your Ticket',
                              style: Theme.of(context).textTheme.button,
                            ),
                            onTap: () {}))
                    .paddingTop(8),
              ],
            ),
          ).paddingAll(MyTheme.cardPadding),
        ),
      ),
    );
  }

  Widget _cardImage() {
    return Flexible(
      flex: 6,
      child: ClipRRect(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: ExtendedImage.network(
                //TODO remove the default image [It's use for testing]
                eventImageUrl ??
                    'https://designshack.net/wp-content/uploads/party-club-flyer-templates.jpg',
                cache: true,
              ).image,
              fit: BoxFit.cover,
              // colorFilter: ColorFilter.mode(Colors.grey, BlendMode.darken),
            ),
          ),
        ),
      ),
    );
  }
}
