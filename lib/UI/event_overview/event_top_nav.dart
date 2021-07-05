import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:badges/badges.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:ticketapp/UI/event_overview/side_buttons.dart';
import 'package:ticketapp/main.dart';
import 'package:ticketapp/model/user.dart';
import 'package:ticketapp/pages/my_ticktes/my_tickets_drawer.dart';
import 'package:ticketapp/pages/reward_center/reward_center_drawer.dart';
import '../../pages/authentication/authentication_drawer.dart';
import 'package:ticketapp/pages/events_overview/events_overview_page.dart';
import 'package:ticketapp/repositories/events_repository.dart';
import 'package:ticketapp/repositories/user_repository.dart';

import '../../utilities/svg/icon.dart';
import '../theme.dart';
import '../widgets/icons/svgicon.dart';
import '../widgets/popups/appollo_popup.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/icons/svgicon.dart';
import 'package:ticketapp/UI/widgets/popups/appollo_popup.dart';
import 'package:ticketapp/utilities/svg/icon.dart';

import 'event_overview_home.dart';

class EventOverviewAppbar extends StatefulWidget {
  final Color color;

  const EventOverviewAppbar({Key key, this.color}) : super(key: key);
  @override
  _EventOverviewAppbarState createState() => _EventOverviewAppbarState();
}

class _EventOverviewAppbarState extends State<EventOverviewAppbar> {
  bool isHoverSearchBar = false;
  final List<Menu> createEventOptions = [Menu('Overview', false), Menu('Pricing', false), Menu('Blog', false)];

  final List<Menu> helpOptions = [
    Menu('Contact Organiser', false),
    Menu('Creating an Event', false),
    Menu('Find my tickets', false),
    Menu('Support Center', false),
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
        color: widget.color ?? MyTheme.appolloBackgroundColor,
        width: screenSize.width,
        height: kToolbarHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                InkWell(
                    onTap: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                      Navigator.popAndPushNamed(context, EventOverviewPage.routeName,
                          arguments: EventsRepository.instance.upcomingPublicEvents);
                    },
                    child: _appolloLogo().paddingHorizontal(50)),
                //TODO: _appolloSearchBar(context, screenSize),
              ],
            ).paddingVertical(4),
            ValueListenableBuilder<User>(
                valueListenable: UserRepository.instance.currentUserNotifier,
                builder: (context, user, child) {
                  if (user != null) {
                    return Row(
                      children: [
                        /*Badge(
                            badgeContent: Text('10'),
                            showBadge: true,
                            alignment: Alignment.topRight,
                            position: BadgePosition.topEnd(end: 5),
                            child: SideButton(title: 'Anouncement', onTap: () {}).paddingRight(8)),
                        Badge(
                            badgeContent: Text('5'),
                            showBadge: true,
                            alignment: Alignment.topRight,
                            position: BadgePosition.topEnd(end: 5),
                            child: SideButton(title: 'My Reminders', onTap: () {}).paddingRight(8)),*/
                        Badge(
                            badgeContent: Text('0'),
                            showBadge: false,
                            alignment: Alignment.topRight,
                            position: BadgePosition.topEnd(end: 5),
                            child: SideButton(
                                title: 'My Rewards',
                                onTap: () {
                                  RewardCenterDrawer.openRewardCenterDrawer();
                                }).paddingRight(8)),
                        Badge(
                            badgeContent: Text('0'),
                            showBadge: false,
                            alignment: Alignment.topRight,
                            position: BadgePosition.topEnd(end: 5),
                            child: SideButton(
                                title: 'My Tickets',
                                onTap: () {
                                  MyTicketsDrawer.openMyTicketsDrawer();
                                }).paddingRight(8)),
                        _appolloHelpDropDown(context).paddingRight(8),
                        _appolloCreateEventDropDown(context).paddingRight(16),
                        _showUserAvatar(context, user).paddingRight(50),
                      ],
                    ).paddingVertical(4);
                  }
                  return Row(
                    children: [
                      _appolloHelpDropDown(context).paddingRight(16).paddingVertical(4),
                      _appolloCreateEventDropDown(context).paddingRight(16).paddingVertical(4),
                      _signInButton(context),
                    ],
                  );
                }),
          ],
        ));
  }

  Widget _appolloSearchBar(BuildContext context, Size screenSize) {
    return InkWell(
      onTap: () {},
      onHover: (v) {
        setState(() => isHoverSearchBar = v);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 10,
            sigmaY: 10,
          ),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: 25,
            width: screenSize.width * 0.4,
            decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: isHoverSearchBar ? MyTheme.appolloWhite.withOpacity(.8) : Colors.transparent,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(4)),
                color: isHoverSearchBar ? MyTheme.appolloGrey.withOpacity(.5) : MyTheme.appolloBackgroundColor),
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(height: 22, child: SvgIcon(AppolloSvgIcon.searchOutline, color: MyTheme.appolloWhite)),
                    Container(
                      child: Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.transparent,
                            contentPadding: const EdgeInsets.only(bottom: 14, left: 12),
                            focusedBorder: InputBorder.none,
                            hintText: 'Search Events',
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                          ),
                        ).paddingBottom(8),
                      ),
                    ),
                  ],
                ).paddingHorizontal(4),
                isHoverSearchBar ? _searchAction(context) : SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Align _searchAction(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        height: 30,
        width: 300,
        child: Row(
          children: [
            Expanded(
              flex: 6,
              child: Container(
                height: 25,
                color: MyTheme.appolloWhite.withAlpha(120),
                child: Row(
                  children: [
                    Container(height: 16, child: SvgIcon(AppolloSvgIcon.perthGps, color: MyTheme.appolloWhite))
                        .paddingRight(4),
                    AutoSizeText('Perth, Australie', style: Theme.of(context).textTheme.button.copyWith(fontSize: 12)),
                  ],
                ).paddingHorizontal(8),
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(
                height: 25,
                color: MyTheme.appolloGreen,
                child: Center(
                  child: AutoSizeText('Search', style: Theme.of(context).textTheme.button.copyWith(fontSize: 12))
                      .paddingHorizontal(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _appolloLogo() => Text("appollo",
      style: MyTheme.textTheme.subtitle1.copyWith(fontFamily: "cocon", color: Colors.white, fontSize: 34, shadows: [
        BoxShadow(color: Colors.black, blurRadius: 1, spreadRadius: 1),
      ]));

  Widget _appolloCreateEventDropDown(BuildContext context) {
    return Container(
        child: AppolloDropdown(
      item: createEventOptions,
      title: 'Create an Event',
      onChange: (s, v) {
        print(s);
        print(v);
      },
    ));
  }

  Widget _appolloHelpDropDown(BuildContext context) => Container(
        child: AppolloDropdown(
          title: 'Help',
          width: 100,
          item: helpOptions,
          onChange: (s, v) {
            print(s);
            print(v);
          },
        ),
      );

  Widget _signInButton(context) => InkWell(
        onTap: () {
          WrapperPage.endDrawer.value = AuthenticationDrawer();
          WrapperPage.mainScaffold.currentState.openEndDrawer();
        },
        child: Container(
          height: kToolbarHeight,
          color: MyTheme.appolloGreen,
          child: Center(
            child: Text('Login Or Sign Up',
                    style: MyTheme.textTheme.button
                        .copyWith(fontWeight: FontWeight.w500, color: MyTheme.appolloBackgroundColor))
                .paddingHorizontal(16),
          ),
        ),
      );

  Widget _showUserAvatar(BuildContext context, User user) => InkWell(
        onTap: () {
          WrapperPage.endDrawer.value = AuthenticationDrawer();
          WrapperPage.mainScaffold.currentState.openEndDrawer();
        },
        child: Row(
          children: [
            Text('${user.getFullName() ?? ''}',
                    style: MyTheme.textTheme.bodyText1.copyWith(fontWeight: FontWeight.w400))
                .paddingRight(16),
            SizedBox(
              width: 50,
              child: CircleAvatar(
                backgroundColor: MyTheme.appolloGreen,
                radius: 50,
                backgroundImage: ExtendedImage.network(UserRepository.instance.currentUser().profileImageURL ?? "",
                    cache: true, fit: BoxFit.cover, loadStateChanged: (ExtendedImageState state) {
                  switch (state.extendedImageLoadState) {
                    case LoadState.loading:
                      return Container(
                        color: Colors.white,
                      );
                    case LoadState.completed:
                      return state.completedWidget;
                    default:
                      return Container(
                        color: Colors.white,
                      );
                  }
                }).image,
              ),
            ),
          ],
        ),
      );
}
