import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme.dart';

class ForMeCard extends StatelessWidget {
  final String title;
  final String subTitle;
  final Color? color;
  final String svgIcon;

  final Widget? child;
  const ForMeCard({
    Key? key,
    required this.title,
    required this.subTitle,
    this.color,
    required this.svgIcon,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: MyTheme.scoopBackgroundColorLight,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(svgIcon, height: 50, width: 50).paddingBottom(8),
          Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                AutoSizeText(
                  title,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: MyTheme.textTheme.headline6!.copyWith(color: color, fontWeight: FontWeight.w400),
                ).paddingBottom(8),
                AutoSizeText(
                  subTitle,
                  maxLines: 4,
                  textAlign: TextAlign.center,
                  style: MyTheme.textTheme.bodyText2!.copyWith(color: MyTheme.scoopWhite, fontSize: 10),
                ).paddingBottom(8),
                Container(
                  child: child ?? Container(),
                )
              ],
            ),
          ),
        ],
      ).paddingAll(8),
    );
  }
}
