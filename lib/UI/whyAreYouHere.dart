import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:webapp/UI/theme.dart';

class WhyAreYouHere extends StatelessWidget {
  final String text;

  const WhyAreYouHere(this.text, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MyTheme.maxWidth,
      child: Container(
        decoration: ShapeDecoration(
            color: MyTheme.appolloGreen,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4)))),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            children: [
              AutoSizeText(
                text,
                style: MyTheme.lightTextTheme.bodyText2,
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 8,
              ),
              AutoSizeText(
                "Follow the instructions below to accept your invite!",
                style: MyTheme.lightTextTheme.bodyText2,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
