import 'package:flutter/material.dart';
import 'package:ticketapp/UI/theme.dart';

class AppolloDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      thickness: 0.8,
      color: MyTheme.appolloGrey.withAlpha(60),
    ).paddingBottom(MyTheme.elementSpacing);
  }
}
