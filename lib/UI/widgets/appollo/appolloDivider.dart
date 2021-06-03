import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../../theme.dart';

class AppolloDivider extends StatelessWidget {
  final double verticalPadding;

  const AppolloDivider({Key key, this.verticalPadding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Divider(
      thickness: 0.8,
      color: MyTheme.appolloGrey.withAlpha(60),
    ).paddingVertical(verticalPadding ??
        getValueForScreenType(
            context: context,
            watch: MyTheme.elementSpacing,
            mobile: MyTheme.elementSpacing,
            tablet: MyTheme.elementSpacing * 2,
            desktop: MyTheme.elementSpacing * 2));
  }
}
