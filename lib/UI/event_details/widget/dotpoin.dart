import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ticketapp/UI/icons.dart';

import '../../theme.dart';

class DotPoint extends StatelessWidget {
  final String text;
  final bool isActive;
  const DotPoint({Key? key, required this.text, this.isActive = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          AppolloIcons.dot,
          height: 8,
          width: 8,
          color: isActive ? MyTheme.scoopGreen : MyTheme.scoopGrey.withOpacity(.3),
        ).paddingRight(16),
        Expanded(
          child: AutoSizeText(
            '$text',
            style: MyTheme.textTheme.caption!.copyWith(
                decoration: isActive ? TextDecoration.none : TextDecoration.lineThrough,
                color: isActive ? MyTheme.textTheme.caption!.color : MyTheme.scoopDimGrey),
          ),
        ),
      ],
    ).paddingBottom(4);
  }
}
