import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:ticketapp/UI/theme.dart';

/// Displays a card telling the user who invited them to this event if an invitation link was used.
class WhyAreYouHereWidget extends StatelessWidget {
  final String text;

  const WhyAreYouHereWidget(this.text, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MyTheme.maxWidth,
      child: Container(
        decoration: ShapeDecoration(
            color: getValueForScreenType(
                context: context,
                watch: MyTheme.appolloGreen,
                mobile: MyTheme.appolloGreen,
                tablet: MyTheme.appolloPurple,
                desktop: MyTheme.appolloPurple),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4)))),
        child: Padding(
          padding:
              EdgeInsets.all(getValueForScreenType(context: context, watch: 8, mobile: 8, tablet: 20, desktop: 20)),
          child: Column(
            crossAxisAlignment: getValueForScreenType(
                context: context,
                watch: CrossAxisAlignment.center,
                mobile: CrossAxisAlignment.center,
                tablet: CrossAxisAlignment.start,
                desktop: CrossAxisAlignment.start),
            children: [
              AutoSizeText(
                text,
                style: MyTheme.lightTextTheme.bodyText2,
                textAlign: getValueForScreenType(
                    context: context,
                    watch: TextAlign.center,
                    mobile: TextAlign.center,
                    tablet: TextAlign.left,
                    desktop: TextAlign.left),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
