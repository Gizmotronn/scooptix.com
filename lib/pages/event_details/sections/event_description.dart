import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../../../UI/widgets/appollo/appolloDivider.dart';
import '../../../model/event.dart';
import '../../../UI/theme.dart';

class EventDescription extends StatelessWidget {
  const EventDescription({
    Key? key,
    required this.event,
  }) : super(key: key);

  final Event event;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Column(
            children: [
              AutoSizeText(
                'Event Details',
                style: MyTheme.textTheme.headline2!.copyWith(color: MyTheme.appolloGreen, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: MyTheme.elementSpacing * 2),
              AutoSizeText("${event.description}", textAlign: TextAlign.center, style: MyTheme.textTheme.subtitle1),
            ],
          ).paddingHorizontal(MyTheme.elementSpacing),
          AppolloDivider(),
        ],
      ),
    );
  }
}
