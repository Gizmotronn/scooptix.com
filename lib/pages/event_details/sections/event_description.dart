import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:ticketapp/UI/event_details/widget/event_title.dart';

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
              EventDetailTitle('Event Details'),
              const SizedBox(height: 30),
              AutoSizeText("${event?.description ?? ''}",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.caption.copyWith(fontWeight: FontWeight.w500)),
            ],
          ).paddingHorizontal(32),
          const SizedBox(height: 30),
          AppolloDivider(),
        ],
      ),
    );
  }
}
