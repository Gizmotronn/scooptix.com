import 'package:auto_size_text/auto_size_text.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:ticketapp/UI/widgets/buttons/card_button.dart';
import 'package:ticketapp/UI/widgets/buttons/heart.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/model/user.dart';
import 'package:ticketapp/pages/event_details/authentication_drawer.dart';
import 'package:ticketapp/pages/event_details/event_detail_page.dart';
import 'package:ticketapp/repositories/user_repository.dart';
import 'package:ticketapp/services/navigator_services.dart';
import 'package:ticketapp/utilities/format_date/full_date_time.dart';

import '../../main.dart';
import '../../UI/theme.dart';

class EventCardDesktop extends StatelessWidget {
  final Event event;
  final double width;

  const EventCardDesktop({Key key, this.event, this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Stack(
      children: [
        Container(
          width: width != null
              ? width - 24
              : screenSize.width > 324 * 4
                  ? screenSize.width / 4 - 24
                  : screenSize.width / 3 - 24,
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: MyTheme.appolloBackgroundColorLight.withOpacity(.2),
                spreadRadius: 5,
                blurRadius: 10,
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _cardImage(),
                _cardContentDesktop(context),
              ],
            ),
          ),
        ).paddingAll(12),
        _tag(context)
      ],
    );
  }

  Widget _tag(BuildContext context) {
    List<int> prices = [];

    bool isSoldOut = event.soldOut();

    for (var i = 0; i < event.getAllReleases().length; i++) {
      final release = event?.getAllReleases()[i];
      prices.add(release?.price == null ? 0 : release.price);
    }
    if (prices.length > 1) {
      prices.sort((a, b) => a.compareTo(b));
    }

    int minPrice = prices.isNotEmpty ? prices.first : 0;
    int maxPrice = prices.isNotEmpty ? prices.last : 0;

    bool checkSamePrice = minPrice == maxPrice;
    final bothPrice = "\$${(minPrice / 100).toStringAsFixed(2)} - \$${(maxPrice / 100).toStringAsFixed(2)}";
    return Builder(
      builder: (context) {
        return _buildTag(context,
            tag: maxPrice < 1 ? "Free" : (checkSamePrice ? "\$${(maxPrice / 100).toStringAsFixed(2)}" : bothPrice),
            isSoldOut: isSoldOut,
            preSale: !isSoldOut && prices.isEmpty);
      },
    );
  }

  Widget _buildTag(BuildContext context, {String tag, bool isSoldOut = false, bool preSale = false}) {
    Color buildColor() {
      if (tag == 'Free') {
        return MyTheme.appolloGreen;
      } else if (isSoldOut) {
        return MyTheme.appolloRed;
      } else if (preSale) {
        return MyTheme.appolloGrey;
      } else {
        return MyTheme.appolloOrange;
      }
    }

    return Positioned(
      right: 0,
      top: 30,
      child: Container(
        height: 35,
        decoration: BoxDecoration(
          color: buildColor(),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: AutoSizeText(
                  isSoldOut
                      ? 'Sold Out'
                      : preSale
                          ? "Pre Sale"
                          : tag,
                  style: MyTheme.lightTextTheme.bodyText2)
              .paddingHorizontal(14),
        ),
      ),
    );
  }

  Widget _cardContentDesktop(BuildContext context) {
    return Flexible(
      child: ClipRRect(
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(12), bottomLeft: Radius.circular(12)),
        child: Container(
          decoration: BoxDecoration(color: MyTheme.appolloCardColor),
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            fullDate(event.date) ?? '',
                            textAlign: TextAlign.start,
                            maxLines: 1,
                            style: MyTheme.lightTextTheme.headline6.copyWith(color: MyTheme.appolloRed),
                          ).paddingBottom(8),
                        ),
                        ValueListenableBuilder<User>(
                            valueListenable: UserRepository.instance.currentUserNotifier,
                            builder: (context, user, child) {
                              return FavoriteHeartButton(
                                onTap: (v) {
                                  if (!v) {
                                    if (user == null) {
                                      WrapperPage.endDrawer.value = AuthenticationDrawer();
                                      WrapperPage.mainScaffold.currentState.openEndDrawer();
                                    } else {
                                      ///TODO Add event as favorite to user
                                      print('Event added to favorite');
                                      user.toggleFavourite(event.docID);
                                    }
                                  }
                                },
                                enable: user != null ? true : false,
                                //TODO if event is favorited, should pass true
                                isFavorite: _checkFavorite(user),
                              );
                            }),
                      ],
                    ),
                    AutoSizeText(
                      event.name ?? '',
                      textAlign: TextAlign.start,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.headline4.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ],
                ).paddingAll(14),
                Align(
                  alignment: Alignment.bottomRight,
                  child: CardButton(
                    title: 'View Event',
                    width: null,
                    deactiveColor: MyTheme.appolloGreen,
                    activeColor: MyTheme.appolloGreen.withOpacity(.9),
                    deactiveColorText: MyTheme.appolloBackgroundColor,
                    activeColorText: MyTheme.appolloWhite,
                    onTap: () {
                      NavigationService.navigateTo(EventDetailPage.routeName,
                          arg: event.docID, queryParams: {'id': event.docID});
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

  Widget _cardContentMobile(BuildContext context) {
    return Flexible(
      child: Container(
        decoration: BoxDecoration(color: MyTheme.appolloCardColor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: AutoSizeText(
                    fullDate(event.date) ?? '',
                    textAlign: TextAlign.start,
                    maxLines: 2,
                    style: MyTheme.lightTextTheme.headline6.copyWith(color: MyTheme.appolloRed),
                  ).paddingBottom(8),
                ),
              ],
            ),
            AutoSizeText(
              event.name ?? '',
              textAlign: TextAlign.start,
              maxLines: 2,
              style: Theme.of(context).textTheme.headline4.copyWith(fontWeight: FontWeight.w500),
            ).paddingBottom(4),
          ],
        ).paddingAll(MyTheme.elementSpacing),
      ),
    );
  }

  Widget _cardImage() {
    return Flexible(
      child: ClipRRect(
        borderRadius: BorderRadius.only(topRight: Radius.circular(12), topLeft: Radius.circular(12)),
        child: event.coverImageURL == null
            ? SizedBox()
            : Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: ExtendedImage.network(
                      event.coverImageURL,
                      cache: true,
                      loadStateChanged: (state) {
                        switch (state.extendedImageLoadState) {
                          case LoadState.loading:
                            return Container(color: Colors.white);
                          case LoadState.completed:
                            return state.completedWidget;
                          case LoadState.failed:
                            return Container(color: Colors.white);
                          default:
                            return Container(color: Colors.white);
                        }
                      },
                    ).image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
      ),
    );
  }

  bool _checkFavorite(User user) {
    if (user != null) {
      return user.favourites.contains(event.docID) ?? false;
    } else {
      return false;
    }
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
                VerticalDivider(color: MyTheme.appolloGrey.withOpacity(.4), width: 0.4),
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
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(12), topRight: Radius.circular(12)),
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
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(color: MyTheme.appolloRed, letterSpacing: 1.5, fontSize: 12),
                    ).paddingBottom(8),
                    AutoSizeText(
                      event.name ?? '',
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      style: Theme.of(context)
                          .textTheme
                          .headline5
                          .copyWith(color: MyTheme.appolloGrey, fontSize: sizes.isDesktop ? null : 14),
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
                            Navigator.of(context).push(MaterialWithModalsPageRoute(
                                builder: (_) => EventDetailPage(
                                      id: event.docID,
                                    )));
                          },
                          borderRadius: BorderRadius.only(bottomRight: Radius.circular(12)),
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
        borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: ExtendedImage.network(
                //TODO remove the default image url [It's use for testing]
                event.coverImageURL ?? 'https://designshack.net/wp-content/uploads/party-club-flyer-templates.jpg',
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
