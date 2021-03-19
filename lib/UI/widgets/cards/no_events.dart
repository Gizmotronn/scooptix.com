import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:ticketapp/UI/widgets/icons/svgicon.dart';
import 'package:ticketapp/utilities/svg/icon.dart';
import '../../theme.dart';

class NoEvents extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          AutoSizeText('No Events Found',
                  style: Theme.of(context)
                      .textTheme
                      .headline4
                      .copyWith(color: MyTheme.appolloDimGrey))
              .paddingBottom(16),
          SvgIcon(
            AppolloSvgIcon.noEvent,
            size: 300,
          ),
        ],
      ),
    ).paddingAll(32);
  }
}
