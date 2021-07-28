import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:ticketapp/UI/event_overview/events.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/appollo/appollo_bottom_sheet.dart';
import 'package:ticketapp/UI/widgets/buttons/apollo_button.dart';
import 'package:ticketapp/UI/widgets/cards/appollo_bg_card.dart';
import 'package:ticketapp/UI/widgets/cards/forme_card.dart';
import 'package:ticketapp/pages/app_bar.dart';
import 'package:ticketapp/pages/authentication/authentication_sheet_wrapper.dart';
import '../../../pages/authentication/authentication_drawer.dart';
import 'package:ticketapp/repositories/events_repository.dart';
import 'package:ticketapp/repositories/user_repository.dart';
import 'package:ticketapp/utilities/svg/icon.dart';

import '../../../main.dart';
import '../event_overview_home.dart';
import '../side_buttons.dart';

class EventsForMe extends StatefulWidget {
  final ScrollController? scrollController;

  const EventsForMe({Key? key, this.scrollController}) : super(key: key);

  @override
  _EventsForMeState createState() => _EventsForMeState();
}

class _EventsForMeState extends State<EventsForMe> {
  List<Menu> _forMe = [
    Menu('Events you may like', false, id: 0, svgIcon: AppolloSvgIcon.calender),
    Menu('Favourite Organisers', false, id: 1, svgIcon: AppolloSvgIcon.people),
    Menu('Events you liked', false, id: 2, svgIcon: AppolloSvgIcon.heart),
  ];

  List<double> positions = [0, 0, 0];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MyTheme.maxWidth,
      child: ValueListenableBuilder(
        valueListenable: UserRepository.instance.currentUserNotifier,
        builder: (c, u, w) {
          return u != null ? _buildForMeLoggedIn() : _buildForMeNotLoggedIn();
        },
      ),
    ).paddingTop(MyTheme.elementSpacing / 2).paddingLeft(MyTheme.elementSpacing).paddingRight(MyTheme.elementSpacing);
  }

  Widget _buildForMeNotLoggedIn() {
    Size screenSize = MediaQuery.of(context).size;
    return ResponsiveBuilder(
      builder: (context, size) {
        if (size.isDesktop || size.isTablet) {
          return Container(
            //height: screenSize.height * 0.5,
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      height: 240,
                      width: MyTheme.maxWidth / 3 - MyTheme.elementSpacing * 2 / 3,
                      child: ForMeCard(
                        title: 'Curated Events',
                        color: MyTheme.appolloGreen,
                        subTitle:
                            'We find events your might be interested in based on your preferences. Making it easier then ever to find something to do.',
                        svgIcon: AppolloSvgIcon.calender,
                      ),
                    ).paddingRight(MyTheme.elementSpacing),
                    SizedBox(
                      height: 240,
                      width: MyTheme.maxWidth / 3 - MyTheme.elementSpacing * 2 / 3,
                      child: ForMeCard(
                        title: 'Follow your favourite organisers',
                        subTitle:
                            'Be the first to see new events from your favourite organisers, simply follow them and we will keep you up to date.',
                        color: MyTheme.appolloOrange,
                        svgIcon: AppolloSvgIcon.people,
                      ),
                    ).paddingRight(MyTheme.elementSpacing),
                    SizedBox(
                      height: 240,
                      width: MyTheme.maxWidth / 3 - MyTheme.elementSpacing * 2 / 3,
                      child: ForMeCard(
                        title: 'Like an event',
                        subTitle:
                            'Liked events will be shown here. Its the easiest way to get back to an event your are interested in.',
                        color: MyTheme.appolloRed,
                        svgIcon: AppolloSvgIcon.heart,
                      ),
                    ),
                  ],
                ).paddingBottom(MyTheme.elementSpacing),
                SizedBox(
                  height: 240,
                  child: ForMeCard(
                    title: 'Create an account and discover the best event based on your preferences',
                    subTitle:
                        'Keep up to date with the latest events from your favourite organisers and find new events based on your preferences when you sign in.',
                    svgIcon: AppolloSvgIcon.person,
                    color: MyTheme.appolloPurple,
                    child: HoverAppolloButton(
                      onTap: () {
                        WrapperPage.endDrawer.value = AuthenticationDrawer();
                        WrapperPage.mainScaffold.currentState!.openEndDrawer();
                      },
                      title: 'Create An Account',
                      color: MyTheme.appolloGreen,
                      hoverColor: MyTheme.appolloGreen,
                      maxWidth: 210,
                      minWidth: 210,
                      fill: true,
                    ).paddingTop(MyTheme.elementSpacing).paddingBottom(MyTheme.elementSpacing),
                  ),
                ),
              ],
            ),
          );
        } else {
          return Container(
            height: size.screenSize.height,
            child: SingleChildScrollView(
              child: Container(
                child: Column(
                  children: [
                    AppolloAppBar(),
                    ForMeCard(
                      title: 'Curated Events',
                      color: MyTheme.appolloGreen,
                      subTitle:
                          'We find events your might be interested in based on your preferences. Making it easier then ever to find something to do.',
                      svgIcon: AppolloSvgIcon.calender,
                    ).paddingBottom(MyTheme.elementSpacing),
                    ForMeCard(
                      title: 'Follow your favourite organisers',
                      subTitle:
                          'Be the first to see new events from your favourite organisers, simply follow them and we will keep you up to date.',
                      color: MyTheme.appolloOrange,
                      svgIcon: AppolloSvgIcon.people,
                    ).paddingBottom(MyTheme.elementSpacing),
                    ForMeCard(
                      title: 'Like an event',
                      subTitle:
                          'Liked events will be shown here. Its the easiest way to get back to an event your are interested in.',
                      color: MyTheme.appolloRed,
                      svgIcon: AppolloSvgIcon.heart,
                    ).paddingBottom(MyTheme.elementSpacing),
                    ForMeCard(
                      title: 'Create an account and discover the best event based on your preferences',
                      subTitle:
                          'Keep up to date with the latest events from your favourite organisers and find new events based on your preferences when you sign in.',
                      svgIcon: AppolloSvgIcon.person,
                      color: MyTheme.appolloPurple,
                      child: Padding(
                        padding: EdgeInsets.only(top: 4.0, left: MyTheme.elementSpacing, right: MyTheme.elementSpacing),
                        child: HoverAppolloButton(
                          onTap: () {
                            showAppolloModalBottomSheet(
                                context: context,
                                backgroundColor: MyTheme.appolloBackgroundColor,
                                expand: true,
                                settings: RouteSettings(name: "authentication_sheet"),
                                builder: (context) => AuthenticationPageWrapper());
                          },
                          title: 'Create An Account',
                          color: MyTheme.appolloGreen,
                          hoverColor: MyTheme.appolloGreen,
                          maxWidth: 400,
                          minWidth: 400,
                          fill: true,
                        ),
                      ),
                    ),
                  ],
                ).paddingHorizontal(MyTheme.elementSpacing).paddingBottom(MyTheme.elementSpacing),
              ),
            ),
          ).appolloCard(color: MyTheme.appolloBackgroundColor, borderRadius: BorderRadius.circular(5));
        }
      },
    );
  }

  Widget _forMeTags(context, {required String icon, required String tag}) => Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(icon, height: 24, width: 24).paddingRight(8),
            AutoSizeText(tag, style: Theme.of(context).textTheme.headline3!.copyWith(color: MyTheme.appolloWhite))
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
          icon: SvgPicture.asset(_forMe[index].svgIcon!, height: 16, width: 16).paddingRight(8),
          isTap: _forMe[index].isTap,
          onTap: () async {
            setState(() {
              for (var i = 0; i < _forMe.length; i++) {
                _forMe[i].isTap = false;
              }
              _forMe[index].isTap = true;
            });
            if (widget.scrollController != null) {
              await widget.scrollController!
                  .animateTo(positions[index], curve: Curves.linear, duration: MyTheme.animationDuration);
            }
          },
        ).paddingHorizontal(16),
      ),
    );
  }

  Widget _buildForMeLoggedIn() {
    return ResponsiveBuilder(
      builder: (context, size) {
        if (size.isTablet || size.isDesktop) {
          return Column(
            children: [
              _forMeNav().paddingBottom(16),
              BoxOffset(
                boxOffset: (offset) => setState(() => positions[_forMe[0].id!] = offset.dy),
                child: AppolloBackgroundCard(
                  child: Column(
                    children: [
                      _forMeTags(context, tag: 'Events you may like', icon: AppolloSvgIcon.calender),
                      const SizedBox(height: 300),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: kToolbarHeight),
              BoxOffset(
                boxOffset: (offset) => setState(() => positions[_forMe[1].id!] = offset.dy),
                child: AppolloBackgroundCard(
                  child: Column(
                    children: [
                      _forMeTags(context, tag: 'Favourite Organisers', icon: AppolloSvgIcon.people),
                      const SizedBox(height: 300),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: kToolbarHeight),
              BoxOffset(
                boxOffset: (offset) => setState(() => positions[_forMe[2].id!] = offset.dy),
                child: AppolloBackgroundCard(
                  child: Column(
                    children: [
                      _forMeTags(context, tag: 'Events you liked', icon: AppolloSvgIcon.heart),
                      AppolloEvents(
                          events: EventsRepository.instance.events
                              .where((element) =>
                                  UserRepository.instance.currentUser()!.favourites.contains(element.docID))
                              .toList()),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: kToolbarHeight),
            ],
          );
        } else {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: MyTheme.elementSpacing / 2),
            color: MyTheme.appolloBackgroundColor,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  AppolloAppBar(),
                  Container(
                    child: Column(
                      children: [
                        _forMeTags(context, tag: 'Events you may like', icon: AppolloSvgIcon.calender),
                        AppolloEvents(events: EventsRepository.instance.upcomingPublicEvents.take(5).toList()),
                      ],
                    ),
                  ).appolloCard(color: MyTheme.appolloBackgroundColorLight).paddingBottom(MyTheme.elementSpacing),
                  Container(
                    child: Column(
                      children: [
                        _forMeTags(context, tag: 'Favourite Organisers', icon: AppolloSvgIcon.people),
                        AppolloEvents(events: EventsRepository.instance.upcomingPublicEvents.take(5).toList()),
                      ],
                    ),
                  ).appolloCard(color: MyTheme.appolloBackgroundColorLight).paddingBottom(MyTheme.elementSpacing),
                  Container(
                    child: Column(
                      children: [
                        _forMeTags(context, tag: 'Events you liked', icon: AppolloSvgIcon.heart),
                        AppolloEvents(
                            events: EventsRepository.instance.events
                                .where((element) =>
                                    UserRepository.instance.currentUser()!.favourites.contains(element.docID))
                                .toList()),
                      ],
                    ),
                  ).appolloCard(color: MyTheme.appolloBackgroundColorLight).paddingBottom(MyTheme.elementSpacing),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
