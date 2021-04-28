import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ticketapp/UI/event_overview/events.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/buttons/apollo_button.dart';
import 'package:ticketapp/UI/widgets/cards/appollo_bg_card.dart';
import 'package:ticketapp/UI/widgets/cards/forme_card.dart';
import 'package:ticketapp/repositories/events_repository.dart';
import 'package:ticketapp/repositories/user_repository.dart';
import 'package:ticketapp/utilities/svg/icon.dart';

import '../event_overview_home.dart';
import '../side_buttons.dart';

class EventsForMe extends StatefulWidget {
  final ScrollController scrollController;

  const EventsForMe({Key key, this.scrollController}) : super(key: key);

  @override
  _EventsForMeState createState() => _EventsForMeState();
}

class _EventsForMeState extends State<EventsForMe> {
  List<Menu> _forMe = [
    Menu('Event you may liked', false, id: 0, svgIcon: AppolloSvgIcon.calender),
    Menu('Favourite Organizers', false, id: 1, svgIcon: AppolloSvgIcon.people),
    Menu('Events you liked', false, id: 2, svgIcon: AppolloSvgIcon.heart),
  ];

  List<double> positions = [0, 0, 0];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return SizedBox(
      width: screenSize.width * 0.8,
      child: UserRepository.instance.currentUser() != null
          ? Column(
              children: [
                _forMeNav().paddingBottom(16),
                BoxOffset(
                  boxOffset: (offset) => setState(() => positions[_forMe[0].id] = offset.dy),
                  child: AppolloBackgroundCard(
                    child: Column(
                      children: [
                        _forMeTags(context, tag: 'Event you may liked', icon: AppolloSvgIcon.calender),
                        const SizedBox(height: 300),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: kToolbarHeight),
                BoxOffset(
                  boxOffset: (offset) => setState(() => positions[_forMe[1].id] = offset.dy),
                  child: AppolloBackgroundCard(
                    child: Column(
                      children: [
                        _forMeTags(context, tag: 'Favourite Organizers', icon: AppolloSvgIcon.people),
                        const SizedBox(height: 300),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: kToolbarHeight),
                BoxOffset(
                  boxOffset: (offset) => setState(() => positions[_forMe[2].id] = offset.dy),
                  child: AppolloBackgroundCard(
                    child: Column(
                      children: [
                        _forMeTags(context, tag: 'Events you liked', icon: AppolloSvgIcon.heart),
                        AppolloEvents(
                            events: EventsRepository.instance.events
                                .where((element) =>
                                    UserRepository.instance.currentUser().favourites.contains(element.docID))
                                .toList()),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: kToolbarHeight),
              ],
            )
          : Container(
              height: screenSize.height * 0.5,
              child: _buildForMe(),
            ),
    );
  }

  Widget _buildForMe() {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              ForMeCard(
                title: 'Curated Events',
                color: MyTheme.appolloGreen,
                subTitle:
                    'We find events your might be interested in based on your preferences. Making it easier then ever to find something to do.',
                svgIcon: AppolloSvgIcon.calender,
              ),
              ForMeCard(
                title: 'Follow your favourite organisers',
                subTitle:
                    'Be the first to see new events from your favourite organisers, simply follow them and we will keep you up to date.',
                color: MyTheme.appolloOrange,
                svgIcon: AppolloSvgIcon.people,
              ),
              ForMeCard(
                title: 'Like an event',
                subTitle:
                    'Liked events will be shown here. Its the easiest way to get back to an event your are interested in.',
                color: MyTheme.appolloRed,
                svgIcon: AppolloSvgIcon.heart,
              ),
            ],
          ),
        ),
        ForMeCard(
          title: 'Create an acount and discover the best event based on your preferences',
          subTitle:
              'Keep up to date with the latest events from your favourite organisers and find new events based on your preferences when you sign in.',
          svgIcon: AppolloSvgIcon.person,
          color: MyTheme.appolloPurple,
          child: HoverAppolloButton(
            title: 'Sign In',
            color: MyTheme.appolloPurple,
            hoverColor: MyTheme.appolloPurple,
            maxHeight: 30,
            minHeight: 25,
            maxWidth: 120,
            minWidth: 100,
            fill: false,
          ).paddingTop(4),
        ),
      ],
    );
  }

  Widget _forMeTags(context, {@required String icon, @required String tag}) => Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(icon, height: 24, width: 24).paddingRight(8),
            AutoSizeText(tag ?? '', style: Theme.of(context).textTheme.headline3.copyWith(color: MyTheme.appolloWhite))
                .paddingBottom(4),
          ],
        ),
      ).paddingHorizontal(16).paddingTop(16);

  Widget _forMeNav() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _forMe.length,
        (index) => SideButton(
          title: "${_forMe[index].title}",
          icon: SvgPicture.asset(_forMe[index].svgIcon, height: 16, width: 16).paddingRight(8),
          isTap: _forMe[index].isTap,
          onTap: () async {
            setState(() {
              for (var i = 0; i < _forMe.length; i++) {
                _forMe[i].isTap = false;
              }
              _forMe[index].isTap = true;
            });
            await widget.scrollController
                .animateTo(positions[index], curve: Curves.linear, duration: MyTheme.animationDuration);
          },
        ).paddingHorizontal(16),
      ),
    );
  }
}
