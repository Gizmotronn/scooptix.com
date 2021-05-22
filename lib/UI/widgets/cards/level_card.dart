import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../theme.dart';

class LevalCard extends StatelessWidget {
  final String icon;
  final double iconSize;

  final List<Widget> children;

  const LevalCard({Key key, @required this.children, @required this.icon, this.iconSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 255,
      width: 250,
      child: Stack(
        children: [
          Positioned(
              top: 25,
              left: 0,
              right: 0,
              height: 220,
              child: Container(
                height: 220,
                width: 250,
              ).appolloCard(borderRadius: BorderRadius.circular(8), color: MyTheme.appolloCardColor)),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 90,
            child: SvgPicture.asset(icon, height: iconSize ?? 90, width: iconSize ?? 90)
                .paddingBottom(MyTheme.cardPadding),
          ),
          Positioned(
              top: 95,
              left: 0,
              right: 0,
              height: 160,
              child: Container(
                  width: 250, height: 160, child: Column(children: children).paddingAll(MyTheme.elementSpacing))),
        ],
      ),
    );
  }
}
