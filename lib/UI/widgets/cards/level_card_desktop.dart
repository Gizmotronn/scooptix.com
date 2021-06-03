import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../theme.dart';

class LevelCardDesktop extends StatelessWidget {
  final String icon;
  final double iconSize;

  final List<Widget> children;

  const LevelCardDesktop({Key key, @required this.children, @required this.icon, this.iconSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 330,
      width: 314,
      child: Stack(
        children: [
          Positioned(
              top: 30,
              left: 0,
              right: 0,
              height: 300,
              child: Container(
                height: 300,
                width: 314,
              ).appolloCard(borderRadius: BorderRadius.circular(16), color: MyTheme.appolloCardColor)),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 115,
            child: SvgPicture.asset(icon, height: iconSize ?? 115, width: iconSize ?? 115)
                .paddingBottom(MyTheme.cardPadding),
          ),
          Positioned(
              top: 120,
              left: 0,
              right: 0,
              height: 210,
              child: Container(
                  width: 314, height: 210, child: Column(children: children).paddingAll(MyTheme.elementSpacing))),
        ],
      ),
    );
  }
}
