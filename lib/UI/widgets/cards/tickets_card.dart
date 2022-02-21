import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ticketapp/UI/event_details/widget/dotpoin.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/model/release_manager.dart';
import '../../../UI/theme.dart';

class TicketCard extends StatefulWidget {
  final ReleaseManager release;
  final Color color;
  final Function onQuantityChanged;
  final Event event;
  const TicketCard(
      {Key? key, required this.release, required this.color, required this.onQuantityChanged, required this.event})
      : super(key: key);

  @override
  _TicketCardState createState() => _TicketCardState();
}

class _TicketCardState extends State<TicketCard> {
  int quantity = 0;
  bool showAvailableTickets = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 305,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        color: MyTheme.scoopCardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(context, text: widget.release.name ?? '', color: widget.color),
          _content(context),
          if (showAvailableTickets) _buildTicketsLeft(),
          if (widget.release.getActiveRelease() != null && !widget.release.markedSoldOut) _incrementPurchaseQuantity(),
        ],
      ),
    ).paddingVertical(16).paddingLeft(10);
  }

  Widget _header(BuildContext context, {required String text, required Color color}) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        color: color,
      ),
      child: Center(
        child: Text(
          text,
          style:
              MyTheme.textTheme.headline6!.copyWith(color: MyTheme.scoopBackgroundColor, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    if (!widget.release.markedSoldOut &&
        widget.release.getActiveRelease() != null &&
        widget.release.getActiveRelease()!.maxTickets > widget.release.getActiveRelease()!.ticketsBought) {
      return Expanded(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                SizedBox(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _priceTag(context,
                          tagName: 'Current Price',
                          price: '${(widget.release.getActiveRelease()!.price! / 100).toStringAsFixed(2)}'),
                      if (widget.release.getFullPrice()! > widget.release.getActiveRelease()!.price!)
                        VerticalDivider(color: MyTheme.scoopWhite),
                      if (widget.release.getFullPrice()! > widget.release.getActiveRelease()!.price!)
                        _priceTag(context,
                            tagName: 'Full Price',
                            price: '${(widget.release.getFullPrice()! / 100).toStringAsFixed(2)}',
                            lineThrough: true),
                    ],
                  ),
                ).paddingBottom(MyTheme.elementSpacing),
                if (widget.release.getFullPrice()! > widget.release.getActiveRelease()!.price!)
                  _saveUp(context,
                          savePrice:
                              ((widget.release.getFullPrice()! - widget.release.getActiveRelease()!.price!) / 100)
                                  .toStringAsFixed(2),
                          countdown:
                              "${widget.release.getActiveRelease()!.releaseEnd!.difference(DateTime.now()).inHours} HOURS")
                      .paddingBottom(MyTheme.elementSpacing),
                ..._buildPerks()
              ],
            ),
          ).paddingTop(MyTheme.elementSpacing).paddingHorizontal(MyTheme.elementSpacing),
        ),
      );
    } else if (widget.release.getNextRelease() != null) {
      if (widget.release.markedSoldOut) {
        return SizedBox(
          height: 372,
          child: Center(
            child: AutoSizeText("Sold Out", style: MyTheme.textTheme.subtitle1, textAlign: TextAlign.center)
                .paddingAll(MyTheme.elementSpacing),
          ),
        );
      }
      if (widget.release.ticketType == TicketType.Staged) {
        int index = widget.release.releases.indexWhere((element) => element.releaseStart!.isAfter(DateTime.now()));
        if (index != -1) {
          return AutoSizeText(
                  "There are currently no tickets of this type available.\n\nThe next release starts on ${DateFormat("dd/MM/yy hh:mm aa").format(widget.release.releases[index].releaseStart!)}",
                  style: MyTheme.textTheme.subtitle1,
                  textAlign: TextAlign.center)
              .paddingAll(MyTheme.elementSpacing);
        } else {
          return SizedBox(
            height: 372,
            child: Center(
              child: AutoSizeText("Sold Out", style: MyTheme.textTheme.subtitle1, textAlign: TextAlign.center)
                  .paddingAll(MyTheme.elementSpacing),
            ),
          );
        }
      } else {
        return SizedBox(
          height: 372,
          child: Center(
            child: AutoSizeText("Sold Out", style: MyTheme.textTheme.subtitle1, textAlign: TextAlign.center)
                .paddingAll(MyTheme.elementSpacing),
          ),
        );
      }
    } else {
      return AutoSizeText("There are currently no tickets of this type available.",
              style: MyTheme.textTheme.subtitle1, textAlign: TextAlign.center)
          .paddingAll(MyTheme.elementSpacing);
    }
  }

  List<Widget> _buildPerks() {
    List<Widget> active = [];
    print(widget.release.availablePerks);
    for (int i = 0; i < widget.event.availablePerks.length; i++) {
      if (widget.release.availablePerks.contains(i)) {
        active.add(DotPoint(
          text: widget.event.availablePerks[i].short,
          isActive: true,
        ));
      } else {
        active.add(DotPoint(
          text: widget.event.availablePerks[i].short,
          isActive: false,
        ));
      }
    }
    return [
      Column(
        children: active,
      ).paddingBottom(MyTheme.elementSpacing)
    ];
  }

  Widget _priceTag(BuildContext context, {required String tagName, required String price, bool lineThrough = false}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AutoSizeText(tagName, style: MyTheme.textTheme.subtitle1!.copyWith(fontWeight: FontWeight.w400))
              .paddingBottom(8),
          AutoSizeText.rich(
              TextSpan(text: '\$$price', children: [TextSpan(text: '+BF', style: MyTheme.textTheme.caption)]),
              style: MyTheme.textTheme.headline2!.copyWith(
                  fontWeight: FontWeight.bold,
                  decoration: lineThrough ? TextDecoration.lineThrough : TextDecoration.none)),
        ],
      );

  Widget _saveUp(BuildContext context, {required String savePrice, required String countdown}) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(width: 0.5, color: MyTheme.scoopDarkRed),
        ),
        height: 36,
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(5), bottomLeft: Radius.circular(5)),
                color: MyTheme.scoopDarkRed,
              ),
              child: Center(
                  child: Text('Save \$$savePrice',
                          style: MyTheme.textTheme.bodyText1!.copyWith(color: MyTheme.scoopBackgroundColor))
                      .paddingHorizontal(4)),
            ),
            Expanded(
              child: Center(
                  child: AutoSizeText('PRICE INCREASE IN $countdown',
                          maxLines: 1,
                          minFontSize: 5,
                          style: MyTheme.textTheme.bodyText2!.copyWith(color: MyTheme.scoopDarkRed))
                      .paddingHorizontal(4)),
            ),
          ],
        ),
      );

  Widget _incrementPurchaseQuantity() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Purchase Quantity'),
          Row(
            children: [
              InkWell(
                onTap: () {
                  if (quantity > 0) {
                    setState(() {
                      quantity--;
                    });
                    if (!showAvailableTickets &&
                        widget.release.getActiveRelease()!.ticketsBought + quantity >=
                            widget.release.getActiveRelease()!.maxTickets) {
                      setState(() {
                        showAvailableTickets = true;
                      });
                    }
                    widget.onQuantityChanged(quantity);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: MyTheme.scoopGrey.withOpacity(.45),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.remove, size: 15, color: MyTheme.scoopWhite).paddingAll(4),
                ),
              ),
              SizedBox(width: 50, child: Center(child: Text("${quantity.toString()}"))),
              InkWell(
                onTap: () {
                  if ((widget.release.getActiveRelease()!.price != 0 || quantity == 0) &&
                      widget.release.getActiveRelease()!.ticketsBought + quantity <
                          widget.release.getActiveRelease()!.maxTickets) {
                    setState(() {
                      quantity++;
                    });
                    if (!showAvailableTickets &&
                        widget.release.getActiveRelease()!.ticketsBought + quantity >=
                            widget.release.getActiveRelease()!.maxTickets) {
                      setState(() {
                        showAvailableTickets = true;
                      });
                    }
                    widget.onQuantityChanged(quantity);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: MyTheme.scoopGrey.withOpacity(.45),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.add, size: 15, color: MyTheme.scoopWhite).paddingAll(4),
                ),
              ),
            ],
          ),
        ],
      ).paddingBottom(MyTheme.elementSpacing).paddingHorizontal(MyTheme.elementSpacing).paddingTop(8);

  _buildTicketsLeft() {
    if (widget.release.getActiveRelease() == null) {
      return SizedBox.shrink();
    } else {
      return Text(
        "There are only ${widget.release.getActiveRelease()!.maxTickets - widget.release.getActiveRelease()!.ticketsBought} tickets left of this release",
        style: MyTheme.textTheme.bodyText2!.copyWith(color: MyTheme.scoopRed),
      ).paddingLeft(MyTheme.elementSpacing);
    }
  }
}
