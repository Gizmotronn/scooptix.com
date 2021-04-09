import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:ticketapp/UI/theme.dart';

class SideButton extends StatelessWidget {
  final String title;
  final bool isTap;
  final Function onTap;

  const SideButton({
    Key key,
    this.title,
    this.isTap,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                      ? MyTheme.appolloGreen
                      : onTap == null
                          ? MyTheme.appolloDimGrey
                          : MyTheme.appolloGrey),
            ).paddingHorizontal(8),
          ),
        );
      }),
    );
  }
}
