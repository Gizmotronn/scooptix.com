import 'package:auto_size_text/auto_size_text.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:ticketapp/UI/services/navigator_services.dart';
import 'package:ticketapp/UI/widgets/buttons/card_button.dart';
import 'package:ticketapp/UI/widgets/buttons/heart.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/model/user.dart';
import '../authentication/authentication_drawer.dart';
import 'package:ticketapp/pages/event_details/event_detail_page.dart';
import 'package:ticketapp/repositories/user_repository.dart';
import 'package:ticketapp/utilities/format_date/full_date_time.dart';

import '../../main.dart';
import '../../UI/theme.dart';

class EventCardDesktop extends StatefulWidget {
  final Event event;
  final double? width;

  const EventCardDesktop({Key? key, required this.event, this.width})
      : super(key: key);

  @override
  _EventCardDesktopState createState() => _EventCardDesktopState();
}

class _EventCardDesktopState extends State<EventCardDesktop> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return InkWell(
      onHover: (v) {
        if (hovering != v) {
          setState(() {
            hovering = v;
          });
        }
      },
      onTap: () {
        Navigator.of(context).push(MaterialWithModalsPageRoute(
            builder: (_) => EventDetailPage(
                  id: widget.event.docID!,
                )));
      },
      child: Stack(
        children: [
          Container(
            width: widget.width != null
                ? widget.width! - 24
                : screenSize.width > 324 * 4
                    ? screenSize.width / 4 - 24
                    : screenSize.width / 3 - 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: MyTheme.scoopBackgroundColorLight.withOpacity(.2),
                  spreadRadius: 5,
                  blurRadius: 10,
                ),
              ],
            ),
            child: AspectRatio(
              aspectRatio: 1,
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
      ),
    );
  }

  Widget _tag(BuildContext context) {
    List<int> prices = [];

    bool isSoldOut = widget.event.soldOut();

    for (var i = 0; i < widget.event.getAllReleases().length; i++) {
      final release = widget.event.getAllReleases()[i];
      prices.add(release.price == null ? 0 : release.price!);
    }
    if (prices.length > 1) {
      prices.sort((a, b) => a.compareTo(b));
    }

    int minPrice = prices.isNotEmpty ? prices.first : 0;
    int maxPrice = prices.isNotEmpty ? prices.last : 0;

    bool checkSamePrice = minPrice == maxPrice;
    final bothPrice =
        "\$${(minPrice / 100).toStringAsFixed(2)} - \$${(maxPrice / 100).toStringAsFixed(2)}";
    return Builder(
      builder: (context) {
        return _buildTag(context,
            tag: maxPrice < 1
                ? "Free"
                : (checkSamePrice
                    ? "\$${(maxPrice / 100).toStringAsFixed(2)}"
                    : bothPrice),
            isSoldOut: isSoldOut,
            preSale: !isSoldOut && prices.isEmpty);
      },
    );
  }

  Widget _buildTag(BuildContext context,
      {required String tag, bool isSoldOut = false, bool preSale = false}) {
    Color buildColor() {
      if (tag == 'Free') {
        return MyTheme.scoopGreen;
      } else if (isSoldOut) {
        return MyTheme.scoopRed;
      } else if (preSale) {
        return MyTheme.scoopGrey;
      } else {
        return MyTheme.scoopOrange;
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
                  style: MyTheme.textTheme.bodyText2)
              .paddingHorizontal(14),
        ),
      ),
    );
  }

  Widget _cardContentDesktop(BuildContext context) {
    return Flexible(
      child: ClipRRect(
        borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(12), bottomLeft: Radius.circular(12)),
        child: Container(
          decoration: BoxDecoration(color: MyTheme.scoopCardColor),
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
                            fullDateWithDay(widget.event.date),
                            textAlign: TextAlign.start,
                            maxLines: 1,
                            style: MyTheme.textTheme.subtitle1!
                                .copyWith(color: MyTheme.scoopRed),
                          ).paddingBottom(8),
                        ),
                        ValueListenableBuilder<User?>(
                            valueListenable:
                                UserRepository.instance.currentUserNotifier,
                            builder: (context, user, child) {
                              return FavoriteHeartButton(
                                onTap: (v) {
                                  if (!v) {
                                    if (user == null) {
                                      WrapperPage.endDrawer.value =
                                          AuthenticationDrawer();
                                      WrapperPage.mainScaffold.currentState!
                                          .openEndDrawer();
                                    } else {
                                      ///TODO Add event as favorite to user
                                      print('Event added to favorite');
                                      user.toggleFavourite(widget.event.docID!);
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
                      widget.event.name,
                      textAlign: TextAlign.start,
                      maxLines: 2,
                      style: Theme.of(context)
                          .textTheme
                          .headline6!
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                  ],
                ).paddingHorizontal(14).paddingTop(8),
                if (hovering)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: CardButton(
                      title: 'View Event',
                      width: null,
                      disabledColor: MyTheme.scoopGreen,
                      activeColor: MyTheme.scoopGreen.withOpacity(.9),
                      disabledColorText: MyTheme.scoopBackgroundColor,
                      activeColorText: MyTheme.scoopWhite,
                      onTap: () {
                        NavigationService.navigateTo(EventDetailPage.routeName,
                            arg: widget.event.docID,
                            queryParams: {'id': widget.event.docID!});
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
        decoration: BoxDecoration(color: MyTheme.scoopCardColor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: AutoSizeText(
                    fullDateWithDay(widget.event.date),
                    textAlign: TextAlign.start,
                    maxLines: 2,
                    style: MyTheme.textTheme.headline6!
                        .copyWith(color: MyTheme.scoopRed),
                  ).paddingBottom(8),
                ),
              ],
            ),
            AutoSizeText(
              widget.event.name,
              textAlign: TextAlign.start,
              maxLines: 2,
              style: Theme.of(context)
                  .textTheme
                  .headline4!
                  .copyWith(fontWeight: FontWeight.w500),
            ).paddingBottom(4),
          ],
        ).paddingAll(MyTheme.elementSpacing),
      ),
    );
  }

  Widget _cardImage() {
    return Flexible(
      child: ClipRRect(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(12), topLeft: Radius.circular(12)),
        child: widget.event.coverImageURL == ""
            ? SizedBox()
            : Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: ExtendedImage.network(
                      widget.event.coverImageURL,
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

  bool _checkFavorite(User? user) {
    if (user != null) {
      return user.favourites.contains(widget.event.docID);
    } else {
      return false;
    }
  }
}

class EventCard2 extends StatelessWidget {
  final Event event;

  const EventCard2({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, SizingInformation sizes) {
      return Container(
        width: sizes.isDesktop ? 500 : 400,
        decoration: BoxDecoration(
          color: MyTheme.scoopWhite,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: MyTheme.scoopGrey.withAlpha(20),
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
                    color: MyTheme.scoopGrey.withOpacity(.4), width: 0.4),
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
          decoration: BoxDecoration(color: MyTheme.scoopWhite),
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      fullDateWithDay(event.date),
                      textAlign: TextAlign.start,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                          color: MyTheme.scoopRed,
                          letterSpacing: 1.5,
                          fontSize: 12),
                    ).paddingBottom(8),
                    AutoSizeText(
                      event.name,
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.headline5!.copyWith(
                          color: MyTheme.scoopGrey,
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
                          color: MyTheme.scoopGreen.withAlpha(40),
                          textColor: MyTheme.scoopGreen,
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: CardButton(
                          title: 'View Event',
                          onTap: () {
                            Navigator.of(context)
                                .push(MaterialWithModalsPageRoute(
                                    builder: (_) => EventDetailPage(
                                          id: event.docID!,
                                        )));
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
                event.coverImageURL,
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
