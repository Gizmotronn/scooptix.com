import 'package:auto_size_text/auto_size_text.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:webapp/UI/theme.dart';
import 'package:webapp/model/event.dart';

import 'dateWidget.dart';

class EventInfoWidget extends StatelessWidget {
  final Axis orientation;
  final Event event;
  final bool showTitleAndImage;

  const EventInfoWidget(this.orientation, this.event, {Key key, this.showTitleAndImage = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    if (orientation == Axis.horizontal) {
      return _buildEventInfoHorizontal(screenSize);
    } else {
      return _buildEventInfoVertical(screenSize);
    }
  }

  // Desktop
  _buildEventInfoHorizontal(Size screenSize) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: MyTheme.maxWidth,
          child: AspectRatio(
            aspectRatio: 1.9,
            child: Card(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(6)),
                child: ExtendedImage.network(event.coverImageURL ?? "", cache: true, fit: BoxFit.cover,
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
                        DateWidget(date: event.date).paddingRight(MyTheme.elementSpacing),
                        SizedBox(
                          height: 63,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AutoSizeText(
                                "${DateFormat.EEEE().format(event.date)} at ${DateFormat.jm().format(event.date)}${event.endTime == null ? "" : " - " + DateFormat.jm().format(event.endTime)}",
                                style: MyTheme.lightTextTheme.headline6.copyWith(color: MyTheme.appolloRed),
                              ),
                              AutoSizeText(
                                event.name,
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
                          child: Container(child: _buildEventInfoText(orientation)).appolloCard),
                      SizedBox(
                        width: MyTheme.elementSpacing,
                      ),
                      SizedBox(
                          width: MyTheme.maxWidth / 3 - (MyTheme.elementSpacing + MyTheme.cardPadding * 2 + 8) / 2,
                          child: Container(
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
                                        event.getAllReleases().length,
                                        (index) => AutoSizeText(
                                                "\$${(event.getAllReleases()[index].price / 100).toStringAsFixed(2)} - ${event.getAllReleases()[index].name}")
                                            .paddingTop(MyTheme.elementSpacing)),
                                  ),
                                )
                              ],
                            ),
                          )).appolloCard),
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
            event.name,
            style: MyTheme.lightTextTheme.headline5,
          ).paddingBottom(MyTheme.cardPadding).paddingTop(MyTheme.cardPadding),
        if (showTitleAndImage)
          Container(
            width: MyTheme.maxWidth - 8,
            child: AspectRatio(
              aspectRatio: 2,
              child: ExtendedImage.network(event.coverImageURL, cache: true, fit: BoxFit.cover,
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
            AutoSizeText("${DateFormat.MMMM().add_d().format(event.date)}, ${DateFormat.y().format(event.date)} ",
                maxLines: 1),
            AutoSizeText(DateFormat.Hm().format(event.date))
          ],
        ),
      ).paddingBottom(8),
    );
    if (event.endTime != null) {
      widgets.add(
        SizedBox(
          width: MyTheme.maxWidth,
          child: Row(
            mainAxisAlignment:
                orientation == Axis.horizontal ? MainAxisAlignment.start : MainAxisAlignment.spaceBetween,
            children: [
              AutoSizeText("${event.date.difference(DateTime.now()).inDays} Days to go ", maxLines: 1),
              if (event.endTime != null)
                AutoSizeText("(Duration ${event.endTime.difference(event.date).inHours} hours)"),
            ],
          ),
        ).paddingBottom(8),
      );
    }
    if (event.address != null) {
      widgets.add(
        SizedBox(
          width: MyTheme.maxWidth,
          child: Row(
            mainAxisAlignment:
                orientation == Axis.horizontal ? MainAxisAlignment.start : MainAxisAlignment.spaceBetween,
            children: [
              AutoSizeText("Location: ", maxLines: 1),
              Expanded(child: AutoSizeText(event.address, maxLines: 1)),
            ],
          ),
        ).paddingBottom(16),
      );
    } else if (event.venueName != null) {
      widgets.add(
        SizedBox(
          width: MyTheme.maxWidth,
          child: Row(
            mainAxisAlignment:
                orientation == Axis.horizontal ? MainAxisAlignment.start : MainAxisAlignment.spaceBetween,
            children: [
              AutoSizeText("Location: ", maxLines: 1),
              AutoSizeText(event.venueName, maxLines: 1),
            ],
          ),
        ).paddingBottom(16),
      );
    }
    /* widgets.add(AutoSizeText(
      "This invitation is valid until ${StringFormatter.getDateTime(widget.linkType.event.date.subtract(Duration(hours: widget.linkType.event.cutoffTimeOffset)), showSeconds: false)}",
      maxLines: 2,
    ));*/
    if (event.invitationMessage != "") {
      widgets.add(AutoSizeText(
        "Conditions:",
        style: MyTheme.lightTextTheme.subtitle2,
      ).paddingBottom(8));
      widgets.add(AutoSizeText(
        event.invitationMessage,
        maxLines: 3,
      ));
    }
    if (orientation == Axis.horizontal && event.description != null) {
      widgets.add(AutoSizeText(
        event.description,
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
