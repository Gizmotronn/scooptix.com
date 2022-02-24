import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ui_basics/ui_basics.dart';

import '../../theme.dart';

class BookingCard extends StatelessWidget {
  final String type;
  final String price;
  final List<IconText> textIcons;
  const BookingCard({Key? key, required this.type, required this.price, required this.textIcons}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      width: 250,
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AutoSizeText('$type',
                        style: Theme.of(context)
                            .textTheme
                            .headline2!
                            .copyWith(fontWeight: FontWeight.w500, color: MyTheme.scoopGreen))
                    .paddingBottom(16),
                AutoSizeText.rich(
                        TextSpan(
                            text: '\$ $price',
                            children: [TextSpan(text: '  +BF', style: Theme.of(context).textTheme.caption)]),
                        style: Theme.of(context).textTheme.headline2!.copyWith(fontWeight: FontWeight.w600))
                    .paddingBottom(14),
                Column(children: textIcons)
              ],
            ),
            ScoopButton(
              title: 'Make A Booking',
              onTap: () {},
              fill: ButtonFill.filled,
              color: MyTheme.scoopGreen,
            ),
          ],
        ).paddingAll(MyTheme.cardPadding),
      ).appolloBlurCard(),
    );
  }
}

class IconText extends StatelessWidget {
  final String icon;
  final double? iconSize;
  final String text;
  final TextStyle? textStyle;
  const IconText({Key? key, required this.icon, required this.text, this.iconSize, this.textStyle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(icon, height: iconSize ?? 24, width: iconSize ?? 24).paddingRight(MyTheme.elementSpacing / 2),
        Expanded(child: AutoSizeText('$text', style: textStyle ?? MyTheme.textTheme.bodyText1)),
      ],
    ).paddingBottom(4);
  }
}
