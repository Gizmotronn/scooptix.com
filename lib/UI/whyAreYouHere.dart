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
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        color: MyTheme.appolloGreen,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            children: [
              AutoSizeText(
                text,
                style: MyTheme.mainTT.bodyText2,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8,),
              AutoSizeText(
                "Follow the instructions below to accept your invite!",
                style: MyTheme.mainTT.bodyText2,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
