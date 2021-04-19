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
      child: Container(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -50,
              left: 15,
              right: 15,
              child: SizedBox(
                height: 250,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SvgPicture.asset(icon, height: iconSize ?? 90, width: iconSize ?? 90)
                        .paddingBottom(MyTheme.cardPadding),
                    Column(children: children),
                  ],
                ),
              ),
            ),
          ],
        ).paddingAll(MyTheme.cardPadding),
      ).appolloTransparentCard(),
    );
  }
}
