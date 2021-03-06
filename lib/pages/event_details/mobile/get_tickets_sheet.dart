import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:ticketapp/UI/theme.dart';

/// Shown at the bottom of the screen containing the event name and a button that scrolls to the ticket selection
class QuickAccessSheet extends StatelessWidget {
  final String mainText;
  final ScrollController controller;
  final String buttonText;
  final double position;

  const QuickAccessSheet(
      {Key? key, required this.mainText, required this.controller, required this.position, required this.buttonText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: ShapeDecoration(
          color: MyTheme.scoopCardColorLight,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(topRight: Radius.circular(8), topLeft: Radius.circular(8)))),
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: AutoSizeText(
              mainText,
              minFontSize: 11,
              overflow: TextOverflow.clip,
              maxLines: 1,
              style: MyTheme.textTheme.headline5!.copyWith(color: MyTheme.scoopGreen),
            ).paddingHorizontal(MyTheme.elementSpacing),
          ),
          Container(
            decoration: ShapeDecoration(
                color: MyTheme.scoopYellow,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(6)))),
            height: 50,
            width: MediaQuery.of(context).size.width / 3 < 140 ? 140 : MediaQuery.of(context).size.width / 3,
            child: InkWell(
              onTap: () {
                controller.animateTo(
                    position - getValueForScreenType(context: context, watch: 30, mobile: 30, tablet: 90, desktop: 90),
                    duration: MyTheme.animationDuration,
                    curve: Curves.easeIn);
              },
              child: Center(
                  child: Text(
                buttonText,
                style: MyTheme.textTheme.button!.copyWith(color: MyTheme.scoopBackgroundColor),
              )),
            ),
          ),
        ],
      ),
    );
  }
}
