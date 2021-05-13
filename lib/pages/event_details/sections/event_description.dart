import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../../../UI/widgets/appollo/appolloDivider.dart';
import '../../../model/event.dart';
import '../../../UI/theme.dart';

class EventDescription extends StatelessWidget {
  const EventDescription({
    Key key,
    this.event,
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
                style:
                    MyTheme.lightTextTheme.headline2.copyWith(color: MyTheme.appolloGreen, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 30),
              AutoSizeText("${event?.description ?? ''}",
                  textAlign: TextAlign.center,
                  style: MyTheme.lightTextTheme.bodyText1.copyWith(fontWeight: FontWeight.w400)),
            ],
          ).paddingHorizontal(32),
          const SizedBox(height: 30),
          AppolloDivider(),
        ],
      ),
    );
  }
}
