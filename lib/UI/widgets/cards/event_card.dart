import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/model/link_type/overview.dart';
import 'package:ticketapp/pages/authentication/authentication_page.dart';
import 'package:ticketapp/utilities/format_date/full_date_time.dart';

import '../../theme.dart';
import '../buttons/card_button.dart';

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({
    Key key,
    this.event,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, SizingInformation sizes) {
      return Stack(
        children: [
          Container(
            width: sizes.isDesktop ? 292 : 292,
            decoration: BoxDecoration(
              color: MyTheme.appolloWhite,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: MyTheme.appolloGrey.withAlpha(20),
                  spreadRadius: 5,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: AspectRatio(
                aspectRatio: 100 / 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _cardImage(),
                    VerticalDivider(
                        color: MyTheme.appolloGrey.withOpacity(.4), width: 0.4),
                    _cardContent(context, sizes),
                  ],
                ),
              ),
            ),
          ).paddingAll(12),
          _buildTag(context, tag: 'Free', isSoldOut: false)
        ],
      );
    });
  }

  Widget _buildTag(BuildContext context, {String tag, bool isSoldOut = false}) {
    return Positioned(
      right: 0,
      top: 30,
      child: Container(
        height: 35,
        decoration: BoxDecoration(
          color: isSoldOut ? MyTheme.appolloRed : MyTheme.appolloGreen,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: AutoSizeText(isSoldOut ? 'Sold Out' : tag,
                  style: Theme.of(context).textTheme.caption)
              .paddingHorizontal(14),
        ),
      ),
    );
  }

  Widget _cardContent(context, SizingInformation sizes) {
    return Flexible(
      child: ClipRRect(
        borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(12), bottomLeft: Radius.circular(12)),
        child: Container(
          decoration: BoxDecoration(color: MyTheme.appolloWhite),
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      fullDate(event.date) ?? '',
                      textAlign: TextAlign.start,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.headline6.copyWith(
                          color: MyTheme.appolloRed,
                          letterSpacing: 1.5,
                          fontSize: 12),
                    ).paddingBottom(8),
                    AutoSizeText(
                      event.name ?? '',
                      textAlign: TextAlign.start,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.headline5.copyWith(
                          color: MyTheme.appolloGrey,
                          fontSize: sizes.isDesktop ? null : 14),
                    ).paddingBottom(4),
                  ],
                ).paddingAll(14),
                Align(
                  alignment: Alignment.bottomRight,
                  child: CardButton(
                    title: 'View Event',
                    onTap: () {
                      final overviewLinkType = OverviewLinkType(event);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) =>
                              AuthenticationPage(overviewLinkType)));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardImage() {
    return Flexible(
      child: ClipRRect(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(12), topLeft: Radius.circular(12)),
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

class EventCard2 extends StatelessWidget {
  final Event event;

  const EventCard2({
    Key key,
    this.event,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, SizingInformation sizes) {
      return Container(
        width: sizes.isDesktop ? 500 : 400,
        decoration: BoxDecoration(
          color: MyTheme.appolloWhite,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: MyTheme.appolloGrey.withAlpha(20),
              spreadRadius: 5,
              blurRadius: 10,
            ),
          ],
        ),
        child: Center(
          child: AspectRatio(
            aspectRatio: 2.9,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _cardImage(),
                VerticalDivider(
                    color: MyTheme.appolloGrey.withOpacity(.4), width: 0.4),
                _cardContent(context, sizes),
              ],
            ),
          ),
        ),
      ).paddingAll(12);
    });
  }

  Widget _cardContent(context, SizingInformation sizes) {
    return Flexible(
      child: ClipRRect(
        borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(12), topRight: Radius.circular(12)),
        child: Container(
          decoration: BoxDecoration(color: MyTheme.appolloWhite),
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      fullDate(event.date) ?? '',
                      textAlign: TextAlign.start,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.headline6.copyWith(
                          color: MyTheme.appolloRed,
                          letterSpacing: 1.5,
                          fontSize: 12),
                    ).paddingBottom(8),
                    AutoSizeText(
                      event.name ?? '',
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.headline5.copyWith(
                          color: MyTheme.appolloGrey,
                          fontSize: sizes.isDesktop ? null : 14),
                    ).paddingBottom(4),
                  ],
                ).paddingAll(14),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: ColorCard(
                          title: '\$200',
                          color: MyTheme.appolloGreen.withAlpha(40),
                          textColor: MyTheme.appolloGreen,
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: CardButton(
                          title: 'View Event',
                          onTap: () {
                            final overviewLinkType = OverviewLinkType(event);
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) =>
                                    AuthenticationPage(overviewLinkType)));
                          },
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardImage() {
    return Flexible(
      child: ClipRRect(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
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
