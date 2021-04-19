import 'package:flutter/material.dart';
import '../../theme.dart';

class AppolloDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      thickness: 0.8,
      color: MyTheme.appolloGrey.withAlpha(60),
    ).paddingBottom(MyTheme.elementSpacing);
  }
}
