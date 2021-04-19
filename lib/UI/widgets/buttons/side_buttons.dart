import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../theme.dart';

class SideButton extends StatelessWidget {
  final String title;
  final bool isTap;
  final Function onTap;
  final Color activeColor;
  final Color disableColor;

  const SideButton({Key key, this.title, this.isTap, this.onTap, this.activeColor, this.disableColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final active = activeColor ?? MyTheme.appolloGreen;
    final deactive = disableColor ?? MyTheme.appolloGreen;

    return InkWell(
      onTap: onTap,
      child: ResponsiveBuilder(builder: (context, SizingInformation size) {
        return Container(
          width: size.deviceScreenType == DeviceScreenType.desktop ? 130 : 80,
          height: size.deviceScreenType == DeviceScreenType.desktop ? 35 : 25,
          child: Center(
            child: AutoSizeText(
              title ?? '',
              style: Theme.of(context).textTheme.button.copyWith(
                  fontSize: size.deviceScreenType == DeviceScreenType.desktop ? null : 12,
                  color: isTap
                      ? active
                      : onTap == null
                          ? MyTheme.appolloDimGrey
                          : deactive),
            ).paddingHorizontal(8),
          ),
        );
      }),
    );
  }
}
