import 'package:auto_size_text/auto_size_text.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:webapp/UI/theme.dart';
import 'package:webapp/model/event.dart';

class EventInfoWidget extends StatelessWidget {

  final Axis orientation;
  final Event event;
  final bool showTitleAndImage;

  const EventInfoWidget(this.orientation, this.event, {Key key, this.showTitleAndImage = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    if(orientation == Axis.horizontal){
      return _buildEventInfoHorizontal(screenSize);
    } else {
      return _buildEventInfoVertical(screenSize);
    }
  }

  // Desktop
  _buildEventInfoHorizontal(Size screenSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: MyTheme.maxWidth / 2 - MyTheme.elementSpacing / 2),
          width: MyTheme.maxWidth / 2 - MyTheme.elementSpacing / 2,
          height: MyTheme.maxWidth / 4,
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
        SizedBox(
          width: MyTheme.elementSpacing,
        ),
        Container(
          constraints: BoxConstraints(maxWidth: MyTheme.maxWidth / 2 - MyTheme.elementSpacing / 2),
          width: MyTheme.maxWidth / 2 - MyTheme.elementSpacing / 2,
          height: MyTheme.maxWidth / 4,
          child: Card(
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12.0), child: _buildEventInfoText()),
          ).appolloCard,
        ),
      ],
    );
  }

  // Mobile
  _buildEventInfoVertical(Size screenSize) {
    return Column(
      children: [
        if(showTitleAndImage) AutoSizeText(
          event.name,
          style: MyTheme.mainTT.headline5,
        ).paddingBottom(MyTheme.cardPadding).paddingTop(MyTheme.cardPadding),
        if(showTitleAndImage) Container(
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
        _buildEventInfoText().paddingAll(8),
      ],
    );
  }

  Widget _buildEventInfoText() {
    List<Widget> widgets = List<Widget>();
    widgets.add(
      Align(
          alignment: Alignment.center,
          child: AutoSizeText("Event details", style: MyTheme.mainTT.headline6).paddingBottom(MyTheme.elementSpacing)),
    );
    widgets.add(
      SizedBox(
        width: MyTheme.maxWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AutoSizeText(
                "${DateFormat.MMMM().add_d().format(event.date)}, ${DateFormat.y().format(event.date)}",
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AutoSizeText("${event.date.difference(DateTime.now()).inDays} Days to go", maxLines: 1),
              AutoSizeText(
                  "(Duration ${event.endTime.difference(event.date).inHours} hours)"),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AutoSizeText("Location: ", maxLines: 1),
              AutoSizeText(event.address, maxLines: 1),
            ],
          ),
        ).paddingBottom(16),
      );
    } else {
      widgets.add(
        SizedBox(
          width: MyTheme.maxWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
        style: MyTheme.mainTT.subtitle2,
      ).paddingBottom(8));
      widgets.add(AutoSizeText(
        event.invitationMessage,
        maxLines: 3,
      ).paddingBottom(8));
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

}
