import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:ticketapp/UI/theme.dart';

class SideButton extends StatelessWidget {
  final String title;
  final bool isTap;
  final Function onTap;
  final Widget icon;

  const SideButton({
    Key key,
    this.title,
    this.isTap = false,
    this.onTap,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ResponsiveBuilder(builder: (context, SizingInformation size) {
        return Container(
          height: size.deviceScreenType == DeviceScreenType.desktop ? 30 : 25,
          child: Row(
            children: [
              icon ?? SizedBox(),
              AutoSizeText(
                title ?? '',
                style: Theme.of(context).textTheme.button.copyWith(
                    fontSize: 10.5,
                    fontWeight: isTap
                        ? FontWeight.w500
                        : onTap == null
                            ? FontWeight.w300
                            : FontWeight.w400,
                    color: isTap
                        ? MyTheme.appolloGreen
                        : onTap == null
                            ? MyTheme.appolloDimGrey
                            : MyTheme.appolloWhite),
              ).paddingHorizontal(8),
            ],
          ),
        );
      }),
    );
  }
}
