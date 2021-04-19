import 'package:flutter/material.dart';
import 'package:ticketapp/UI/event_overview/event_overview_home.dart';
import 'package:ticketapp/model/organizer.dart';
import '../../../UI/theme.dart';
import '../../../UI/widgets/appollo/appolloDivider.dart';
import '../../../UI/widgets/buttons/apollo_button.dart';
import '../../../UI/widgets/buttons/card_button.dart';
import '../../../model/event.dart';
import 'counter.dart';
import 'detail_with_button.dart';
import 'event_title.dart';

class EventDetailWithCountdown extends StatelessWidget {
  final List<Menu> tabButtons;
  final ScrollController controller;
  const EventDetailWithCountdown(
      {Key key, @required this.event, @required this.organizer, @required this.tabButtons, @required this.controller})
      : super(key: key);

  final Event event;
  final Organizer organizer;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EventDetailWithButtons(
          event: event,
          organizer: organizer,
          buttons: List.generate(
            tabButtons.length,
            (index) => CardButton(
              title: tabButtons[index].title,
              borderRadius: BorderRadius.circular(5),
              activeColor: MyTheme.appolloGreen,
              deactiveColor: MyTheme.appolloGrey.withAlpha(140),
              activeColorText: MyTheme.appolloWhite,
              deactiveColorText: MyTheme.appolloGreen,
              onTap: () async {
                if (tabButtons[index].position != null) {
                  await controller.animateTo(tabButtons[index].position,
                      curve: Curves.linear, duration: MyTheme.animationDuration);
                }
              },
            ),
          ),
        ),
        EventDetailTitle('Countdown to Pre-Sale Registration'),
        const SizedBox(height: 32),
        SizedBox(
          width: 432,
          child: Container(
            child: Row(
              children: [
                Expanded(child: AppolloCounter(duration: _duration(event.date), countDownType: CountDownType.inDays)),
                const SizedBox(width: 8),
                Expanded(child: AppolloCounter(duration: _duration(event.date), countDownType: CountDownType.inHours)),
                const SizedBox(width: 8),
                Expanded(
                    child: AppolloCounter(duration: _duration(event.date), countDownType: CountDownType.inMinutes)),
              ],
            ).paddingAll(8),
          ).appolloCard(),
        ),
        const SizedBox(height: 32),
        AppolloButton.wideButton(
          heightMax: 40,
          heightMin: 40,
          child: Center(
            child: Text(
              'REMIND ME',
              style: Theme.of(context).textTheme.button.copyWith(color: MyTheme.appolloDarkBlue),
            ),
          ),
          onTap: () {},
          color: MyTheme.appolloGreen,
        ),
        const SizedBox(height: 32),
        AppolloDivider(),
      ],
    );
  }

  Duration _duration(DateTime time) => time.difference(DateTime.now());
}
