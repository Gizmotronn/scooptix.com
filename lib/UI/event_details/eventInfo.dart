import 'package:auto_size_text/auto_size_text.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/model/link_type/birthdayList.dart';
import 'package:ticketapp/model/link_type/link_type.dart';
import 'package:ticketapp/model/link_type/promoterInvite.dart';

import 'dateWidget.dart';
import 'whyAreYouHere.dart';

/// Displays general event info
/// Use Axis.horizontal for desktop and Axis.vertical for mobile.
class EventInfoWidget extends StatelessWidget {
  final Axis orientation;
  final LinkType linkType;
  final bool showTitleAndImage;

  const EventInfoWidget(this.orientation, this.linkType, {Key key, this.showTitleAndImage = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    if (orientation == Axis.horizontal) {
      return _buildEventInfoHorizontal(screenSize, context);
    } else {
      return _buildEventInfoVertical(screenSize);
    }
  }

  // Desktop
  _buildEventInfoHorizontal(Size screenSize, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: MyTheme.maxWidth + 8,
          child: AspectRatio(
            aspectRatio: 1.9,
            child: Card(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(6)),
                child: ExtendedImage.network(linkType.event.coverImageURL ?? "", cache: true, fit: BoxFit.cover,
                    loadStateChanged: (ExtendedImageState state) {
                  switch (state.extendedImageLoadState) {
                    case LoadState.loading:
                      return Container(
                        color: Colors.white,
                      );
                    case LoadState.completed:
                      return state.completedWidget;
                    default:
                      return Container(
                        color: Colors.white,
                      );
                  }
                }),
              ),
            ),
          ),
        ),
        SizedBox(
          height: MyTheme.elementSpacing,
        ),
        if (linkType is PromoterInvite)
          WhyAreYouHereWidget(
                  "${(linkType as PromoterInvite).promoter.firstName} ${(linkType as PromoterInvite).promoter.lastName} has invited you to an event.")
              .paddingBottom(MyTheme.elementSpacing),
        if (linkType is Booking)
          WhyAreYouHereWidget(
                  "${(linkType as Booking).promoter.firstName} ${(linkType as Booking).promoter.lastName} has invited you to their birthday party.")
              .paddingBottom(MyTheme.elementSpacing),
        SizedBox(
          width: MyTheme.maxWidth,
          child: Container(
            child: Padding(
              padding: EdgeInsets.all(MyTheme.cardPadding),
              child: Column(
                children: [
                  SizedBox(
                    //width: MyTheme.maxWidth,
                    height: 63,
                    child: Row(
                      children: [
                        DateWidget(date: linkType.event.date).paddingRight(MyTheme.elementSpacing),
                        SizedBox(
                          height: 63,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AutoSizeText(
                                "${DateFormat.EEEE().format(linkType.event.date)} at ${DateFormat.jm().format(linkType.event.date)}${linkType.event.endTime == null ? "" : " - " + DateFormat.jm().format(linkType.event.endTime)}",
                                style: MyTheme.lightTextTheme.headline6.copyWith(color: MyTheme.appolloRed),
                              ),
                              AutoSizeText(
                                linkType.event.name,
                                style: MyTheme.lightTextTheme.headline4,
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ).paddingBottom(MyTheme.elementSpacing),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                          width: MyTheme.maxWidth / 3 * 2 - (MyTheme.elementSpacing + MyTheme.cardPadding * 2 + 8) / 2,
                          child: Container(child: _buildEventInfoText(Axis.horizontal)).appolloCard),
                      SizedBox(
                        width: MyTheme.elementSpacing,
                      ),
                      SizedBox(
                          width: MyTheme.maxWidth / 3 - (MyTheme.elementSpacing + MyTheme.cardPadding * 2 + 8) / 2,
                          child: Column(
                            children: [
                              SizedBox(
                                width:
                                    MyTheme.maxWidth / 3 - (MyTheme.elementSpacing + MyTheme.cardPadding * 2 + 8) / 2,
                                height: 34,
                                child: RaisedButton(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  padding: EdgeInsets.symmetric(horizontal: MyTheme.cardPadding),
                                  color: MyTheme.appolloGreen,
                                  onPressed: () {
                                    Scaffold.of(context).openEndDrawer();
                                  },
                                  child: Text(
                                    "GET YOUR TICKET",
                                    style: MyTheme.darkTextTheme.button,
                                  ),
                                ),
                              ).paddingBottom(MyTheme.elementSpacing),
                              Container(
                                  child: Padding(
                                padding: EdgeInsets.all(MyTheme.cardPadding),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AutoSizeText("Ticket Types", style: MyTheme.lightTextTheme.headline6),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: List.generate(
                                            linkType.event.releaseManagers.length,
                                            (index) => linkType.event.releaseManagers[index].getActiveRelease() == null
                                                ? SizedBox.shrink()
                                                : AutoSizeText(
                                                        "\$${(linkType.event.releaseManagers[index].getActiveRelease().price / 100).toStringAsFixed(2)} - ${linkType.event.releaseManagers[index].name}")
                                                    .paddingTop(MyTheme.elementSpacing)),
                                      ),
                                    )
                                  ],
                                ),
                              )).appolloCard,
                            ],
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ).appolloCard,
        ),
      ],
    );
  }

  // Mobile
  _buildEventInfoVertical(Size screenSize) {
    return Column(
      children: [
        if (showTitleAndImage)
          AutoSizeText(
            linkType.event.name,
            style: MyTheme.lightTextTheme.headline5,
            textAlign: TextAlign.center,
          ).paddingBottom(MyTheme.cardPadding).paddingTop(MyTheme.cardPadding),
        if (showTitleAndImage)
          Container(
            width: MyTheme.maxWidth - 8,
            child: AspectRatio(
              aspectRatio: 2,
              child: ExtendedImage.network(linkType.event.coverImageURL, cache: true, fit: BoxFit.cover,
                  loadStateChanged: (ExtendedImageState state) {
                switch (state.extendedImageLoadState) {
                  case LoadState.loading:
                    return Container(
                      color: Colors.white,
                    );
                  case LoadState.completed:
                    return state.completedWidget;
                  default:
                    return Container(
                      color: Colors.white,
                    );
                }
              }),
            ),
          ),
        _buildEventInfoText(orientation),
      ],
    );
  }

  Widget _buildEventInfoText(Axis orientation) {
    List<Widget> widgets = List<Widget>();
    widgets.add(
      Align(
          alignment: orientation == Axis.horizontal ? Alignment.centerLeft : Alignment.center,
          child: AutoSizeText("Event details", style: MyTheme.lightTextTheme.headline6)
              .paddingBottom(MyTheme.elementSpacing)),
    );
    widgets.add(
      SizedBox(
        width: MyTheme.maxWidth,
        child: Row(
          mainAxisAlignment: orientation == Axis.horizontal ? MainAxisAlignment.start : MainAxisAlignment.spaceBetween,
          children: [
            AutoSizeText(
                "${DateFormat.MMMM().add_d().format(linkType.event.date)}, ${DateFormat.y().format(linkType.event.date)} ",
                maxLines: 1),
            AutoSizeText(DateFormat.Hm().format(linkType.event.date))
          ],
        ),
      ).paddingBottom(8),
    );
    if (linkType.event.endTime != null) {
      widgets.add(
        SizedBox(
          width: MyTheme.maxWidth,
          child: Row(
            mainAxisAlignment:
                orientation == Axis.horizontal ? MainAxisAlignment.start : MainAxisAlignment.spaceBetween,
            children: [
              AutoSizeText("${linkType.event.date.difference(DateTime.now()).inDays} Days to go ", maxLines: 1),
              if (linkType.event.endTime != null)
                AutoSizeText("(Duration ${linkType.event.endTime.difference(linkType.event.date).inHours} hours)"),
            ],
          ),
        ).paddingBottom(8),
      );
    }
    if (linkType.event.address != null) {
      widgets.add(
        SizedBox(
          width: MyTheme.maxWidth,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment:
                orientation == Axis.horizontal ? MainAxisAlignment.start : MainAxisAlignment.spaceBetween,
            children: [
              AutoSizeText("Location: ", maxLines: 1),
              Expanded(child: AutoSizeText(linkType.event.address, maxLines: 2)),
            ],
          ),
        ).paddingBottom(16),
      );
    } else if (linkType.event.venueName != null) {
      widgets.add(
        SizedBox(
          width: MyTheme.maxWidth,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment:
                orientation == Axis.horizontal ? MainAxisAlignment.start : MainAxisAlignment.spaceBetween,
            children: [
              AutoSizeText("Location: ", maxLines: 1),
              Expanded(child: AutoSizeText(linkType.event.venueName, maxLines: 2)),
            ],
          ),
        ).paddingBottom(16),
      );
    }
    /* widgets.add(AutoSizeText(
      "This invitation is valid until ${StringFormatter.getDateTime(widget.linkType.event.event.date.subtract(Duration(hours: widget.linkType.event.event.cutoffTimeOffset)), showSeconds: false)}",
      maxLines: 2,
    ));*/
    if (linkType.event.invitationMessage != "") {
      widgets.add(AutoSizeText(
        "Conditions:",
        style: MyTheme.lightTextTheme.subtitle2,
      ).paddingBottom(8));
      widgets.add(AutoSizeText(
        linkType.event.invitationMessage,
        maxLines: 3,
      ));
    }
    if (orientation == Axis.horizontal && linkType.event.description != null) {
      widgets.add(AutoSizeText(
        linkType.event.description.replaceAll("\\n", "\n"),
        style: MyTheme.lightTextTheme.bodyText1,
      ).paddingBottom(8));
    }
    return Padding(
      padding: EdgeInsets.all(MyTheme.cardPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      ),
    );
  }
}
