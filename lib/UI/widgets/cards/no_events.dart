import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ticketapp/UI/icons.dart';
import '../../theme.dart';

class NoEvents extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          AutoSizeText('No Events Found',
                  style: Theme.of(context).textTheme.headline4!.copyWith(color: MyTheme.scoopDimGrey))
              .paddingBottom(16),
          SvgPicture.asset(
            AppolloIcons.noEvent,
            height: 300,
            width: 300,
          ),
        ],
      ),
    ).paddingAll(32);
  }
}
