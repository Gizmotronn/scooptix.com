import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:ticketapp/UI/event_details/widget/dotpoin.dart';
import 'package:ticketapp/model/release_manager.dart';
import '../../../UI/theme.dart';

class TicketCard extends StatefulWidget {
  final ReleaseManager release;
  final Color color;
  const TicketCard({Key key, this.release, this.color}) : super(key: key);

  @override
  _TicketCardState createState() => _TicketCardState();
}

class _TicketCardState extends State<TicketCard> {
  int quantity = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 255,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
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
    ).paddingVertical(8).paddingLeft(8);
  }

  Widget _header(BuildContext context, {String text, Color color}) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
        color: color,
      ),
      child: Center(
        child: Text(
          text,
          style: Theme.of(context).textTheme.headline6.copyWith(color: MyTheme.appolloBackgroundColor),
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
                          savePrice: "${widget.release.getFullPrice() - widget.release.getActiveRelease().price}",
                          countdown:
                              "${widget.release.getActiveRelease().releaseEnd.difference(DateTime.now()).inHours} HOURS")
                      .paddingBottom(16),
                Column(
                  children: List.generate(
                      widget.release.getActiveRelease().includedPerks.length,
                      (index) =>
                          DotPoint(text: widget.release.getActiveRelease().includedPerks[index], isActive: true)),
                ),
                Column(
                  children: List.generate(
                      widget.release.getActiveRelease().includedPerks.length,
                      (index) =>
                          DotPoint(text: widget.release.getActiveRelease().excludedPerks[index], isActive: false)),
                ),
              ],
            ),
          ).paddingTop(MyTheme.elementSpacing).paddingHorizontal(MyTheme.elementSpacing),
        ),
      );
    } else {
      return AutoSizeText("There are currently no tickets of this type available.",
              style: MyTheme.lightTextTheme.subtitle1, textAlign: TextAlign.center)
          .paddingAll(8)
          .paddingTop(MyTheme.elementSpacing);
    }
  }

  Widget _priceTag(BuildContext context,
          {@required String tagName, @required String price, bool lineThrough = false}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AutoSizeText(tagName, style: Theme.of(context).textTheme.subtitle1.copyWith(fontWeight: FontWeight.w400))
              .paddingBottom(8),
          AutoSizeText.rich(
              TextSpan(
                  text: '\$ $price', children: [TextSpan(text: '+BF', style: Theme.of(context).textTheme.caption)]),
              style: Theme.of(context).textTheme.headline2.copyWith(
                  fontWeight: FontWeight.bold,
                  decoration: lineThrough ? TextDecoration.lineThrough : TextDecoration.none)),
        ],
      );

  Widget _saveUp(BuildContext context, {String savePrice, String countdown}) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(width: 0.5, color: MyTheme.appolloDarkRed),
        ),
        height: 30,
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(5), bottomLeft: Radius.circular(5)),
                color: MyTheme.appolloDarkRed,
              ),
              child: Center(
                  child: Text('Save \$$savePrice',
                          style: Theme.of(context)
                              .textTheme
                              .caption
                              .copyWith(color: MyTheme.appolloBackgroundColor, fontSize: 10))
                      .paddingHorizontal(4)),
            ),
            Expanded(
              child: Center(
                  child: Text('PRICE INCREASE IN $countdown',
                          style: Theme.of(context)
                              .textTheme
                              .caption
                              .copyWith(color: MyTheme.appolloDarkRed, fontSize: 8.5))
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
                    quantity--;
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
              Text("${quantity.toString()}").paddingHorizontal(12),
              InkWell(
                onTap: () {
                  quantity++;
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
