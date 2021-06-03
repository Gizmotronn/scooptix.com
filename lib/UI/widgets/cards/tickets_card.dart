import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ticketapp/UI/event_details/widget/dotpoin.dart';
import 'package:ticketapp/model/release_manager.dart';
import '../../../UI/theme.dart';

class TicketCard extends StatefulWidget {
  final ReleaseManager release;
  final Color color;
  final Function onQuantityChanged;
  const TicketCard({Key key, this.release, this.color, this.onQuantityChanged}) : super(key: key);

  @override
  _TicketCardState createState() => _TicketCardState();
}

class _TicketCardState extends State<TicketCard> {
  int quantity = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 305,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        color: MyTheme.appolloCardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(context, text: widget.release.name ?? '', color: widget.color),
          _content(context),
          if (widget.release.getActiveRelease() != null) _incrementPurchaseQuatity(),
        ],
      ),
    ).paddingVertical(16).paddingLeft(10);
  }

  Widget _header(BuildContext context, {String text, Color color}) {
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
              MyTheme.textTheme.headline6.copyWith(color: MyTheme.appolloBackgroundColor, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    if (widget.release.getActiveRelease() != null) {
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
                          price: '${(widget.release.getActiveRelease().price / 100).toStringAsFixed(2)}'),
                      if (widget.release.getFullPrice() > widget.release.getActiveRelease().price)
                        VerticalDivider(color: MyTheme.appolloWhite),
                      if (widget.release.getFullPrice() > widget.release.getActiveRelease().price)
                        _priceTag(context,
                            tagName: 'Full Price',
                            price: '${(widget.release.getFullPrice() / 100).toStringAsFixed(2)}',
                            lineThrough: true),
                    ],
                  ),
                ).paddingBottom(16),
                if (widget.release.getFullPrice() > widget.release.getActiveRelease().price)
                  _saveUp(context,
                          savePrice: ((widget.release.getFullPrice() - widget.release.getActiveRelease().price) / 100)
                              .toStringAsFixed(2),
                          countdown:
                              "${widget.release.getActiveRelease().releaseEnd.difference(DateTime.now()).inHours} HOURS")
                      .paddingBottom(16),
                Column(
                  children: List.generate(widget.release.includedPerks.length,
                      (index) => DotPoint(text: widget.release.includedPerks[index], isActive: true)),
                ),
                Column(
                  children: List.generate(widget.release.includedPerks.length,
                      (index) => DotPoint(text: widget.release.excludedPerks[index], isActive: false)),
                ),
              ],
            ),
          ).paddingTop(MyTheme.elementSpacing).paddingHorizontal(MyTheme.elementSpacing),
        ),
      );
    } else if (widget.release.getNextRelease() != null) {
      return AutoSizeText(
              "There are currently no tickets of this type available.\n\nThe next release starts on ${DateFormat("dd/MM/yy hh:mm aa").format(widget.release.getNextRelease().releaseStart)}",
              style: MyTheme.textTheme.subtitle1,
              textAlign: TextAlign.center)
          .paddingAll(MyTheme.elementSpacing);
    } else {
      return AutoSizeText("There are currently no tickets of this type available.",
              style: MyTheme.textTheme.subtitle1, textAlign: TextAlign.center)
          .paddingAll(MyTheme.elementSpacing);
    }
  }

  Widget _priceTag(BuildContext context,
          {@required String tagName, @required String price, bool lineThrough = false}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AutoSizeText(tagName, style: MyTheme.textTheme.subtitle1.copyWith(fontWeight: FontWeight.w400))
              .paddingBottom(8),
          AutoSizeText.rich(
              TextSpan(text: '\$$price', children: [TextSpan(text: '+BF', style: MyTheme.textTheme.caption)]),
              style: MyTheme.textTheme.headline2.copyWith(
                  fontWeight: FontWeight.bold,
                  decoration: lineThrough ? TextDecoration.lineThrough : TextDecoration.none)),
        ],
      );

  Widget _saveUp(BuildContext context, {String savePrice, String countdown}) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(width: 0.5, color: MyTheme.appolloDarkRed),
        ),
        height: 36,
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(5), bottomLeft: Radius.circular(5)),
                color: MyTheme.appolloDarkRed,
              ),
              child: Center(
                  child: Text('Save \$$savePrice',
                          style: MyTheme.textTheme.bodyText1.copyWith(color: MyTheme.appolloBackgroundColor))
                      .paddingHorizontal(4)),
            ),
            Expanded(
              child: Center(
                  child: AutoSizeText('PRICE INCREASE IN $countdown',
                          maxLines: 1,
                          minFontSize: 5,
                          style: MyTheme.textTheme.bodyText2.copyWith(color: MyTheme.appolloDarkRed))
                      .paddingHorizontal(4)),
            ),
          ],
        ),
      );

  Widget _incrementPurchaseQuatity() => Row(
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
                    widget.onQuantityChanged(quantity);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: MyTheme.appolloGrey.withOpacity(.45),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.remove, size: 15, color: MyTheme.appolloWhite).paddingAll(4),
                ),
              ),
              SizedBox(width: 50, child: Center(child: Text("${quantity.toString()}"))),
              InkWell(
                onTap: () {
                  if (widget.release.getActiveRelease().price != 0 || quantity == 0) {
                    setState(() {
                      quantity++;
                    });
                    widget.onQuantityChanged(quantity);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: MyTheme.appolloGrey.withOpacity(.45),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.add, size: 15, color: MyTheme.appolloWhite).paddingAll(4),
                ),
              ),
            ],
          ),
        ],
      ).paddingBottom(MyTheme.elementSpacing).paddingHorizontal(MyTheme.elementSpacing).paddingTop(8);
}
