import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/icons.dart';

class ScooptixLogo extends StatelessWidget {
  const ScooptixLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          AppolloIcons.logoText,
          height: 22,
        ).paddingTop(10),
        SvgPicture.asset(
          AppolloIcons.logoIcon,
          height: 20,
          width: 20,
        ),
      ],
    );
  }
}
