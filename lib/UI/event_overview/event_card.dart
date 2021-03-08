import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:ticketapp/UI/widgets/apollo_button.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/model/link_type/overview.dart';
import 'package:ticketapp/pages/authentication/authentication_page.dart';

import '../theme.dart';

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({
    Key key,
    this.event,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, SizingInformation sizes) {
      return Container(
        width: sizes.isDesktop ? 600 : 450,
        decoration: BoxDecoration(
            color: MyTheme.appolloWhite,
            border: Border.all(width: 0.5, color: MyTheme.appolloGrey),
            borderRadius: BorderRadius.circular(6)),
        child: Center(
          child: AspectRatio(
            aspectRatio: 1.9,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _cardContent(context, sizes),
                VerticalDivider(
                    color: MyTheme.appolloGrey.withOpacity(.8), width: 0.4),
                _cardImage(),
              ],
            ),
          ),
        ),
      ).paddingAll(12);
    });
  }

  Widget _cardContent(context, SizingInformation sizes) {
    return Flexible(
      flex: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(6), bottomLeft: Radius.circular(6)),
        child: Container(
          decoration: BoxDecoration(
            color: MyTheme.appolloWhite,
          ),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AutoSizeText(
                  event.name ?? '',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.headline2.copyWith(
                      color: MyTheme.appolloPurple,
                      letterSpacing: 1.5,
                      fontSize: sizes.isDesktop ? null : 18),
                ).paddingBottom(8),
                Icon(Icons.place, color: MyTheme.appolloPurple)
                    .paddingBottom(4),
                AutoSizeText(
                  event.address ?? '',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.headline5.copyWith(
                      color: MyTheme.appolloGrey,
                      fontSize: sizes.isDesktop ? null : 12),
                ).paddingBottom(4),
                AutoSizeText(
                  "${DateFormat().add_Hm().format(event.date)} - ${DateFormat().add_Hm().format(event.endTime)}",
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.headline3.copyWith(
                      color: MyTheme.appolloGrey,
                      fontSize: sizes.isDesktop ? null : 12),
                ).paddingBottom(10),
                AppolloButton.smallButton(
                    color: Colors.transparent,
                    child: AutoSizeText('View Event',
                        maxLines: 2,
                        style: Theme.of(context)
                            .textTheme
                            .button
                            .copyWith(color: MyTheme.appolloPurple)),
                    onTap: () {
                      final linkType = OverviewLinkType(event);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  AuthenticationPage(linkType)));
                    }),
                Container(
                  child: AppolloButton.smallButton(
                      child: AutoSizeText(
                        'Get Your Ticket',
                        style: Theme.of(context).textTheme.button,
                        maxLines: 2,
                      ),
                      onTap: () {}),
                ).paddingTop(8),
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
            topRight: Radius.circular(6), bottomRight: Radius.circular(6)),
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: ExtendedImage.network(
                //TODO remove the default image url [It's use for testing]
                event.coverImageURL ??
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
