import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../theme.dart';

class LevelCard extends StatelessWidget {
  final String icon;
  final double? iconSize;
  final bool isMobile;

  final List<Widget> children;

  const LevelCard({Key? key, required this.isMobile, required this.children, required this.icon, this.iconSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double prizeWidth = MyTheme.maxWidth / 2 / 3 - MyTheme.elementSpacing * 2;
    if (prizeWidth < 250) {
      prizeWidth = 250;
    }
    return SizedBox(
      height: prizeWidth + prizeWidth * 0.1,
      width: prizeWidth,
      child: Stack(
        children: [
          Positioned(
              top: prizeWidth * 0.1,
              left: 0,
              right: 0,
              height: prizeWidth * 0.9,
              child: Container(
                height: prizeWidth - prizeWidth * 0.1,
                width: prizeWidth,
              ).appolloCard(borderRadius: BorderRadius.circular(16))),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: prizeWidth / 2.2,
            child: SvgPicture.asset(icon, height: iconSize ?? prizeWidth / 2.2, width: iconSize ?? prizeWidth / 2.2)
                .paddingBottom(MyTheme.elementSpacing),
          ),
          Positioned(
              top: prizeWidth / 2.2 - prizeWidth * 0.1 + 8,
              left: 0,
              right: 0,
              height: prizeWidth - prizeWidth / 2.2 + prizeWidth * 0.1 - 8,
              child: Container(
                  width: prizeWidth,
                  height: prizeWidth - prizeWidth / 2.2 + prizeWidth * 0.1,
                  child: Column(children: children).paddingAll(MyTheme.elementSpacing))),
        ],
      ),
    ).paddingRight(MyTheme.elementSpacing / 2).paddingLeft(MyTheme.elementSpacing / 2);
  }
}
