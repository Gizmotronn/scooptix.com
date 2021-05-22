import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/repositories/events_repository.dart';
import 'package:ticketapp/repositories/user_repository.dart';
import 'package:ticketapp/utilities/svg/icon.dart';
import 'authentication/authentication_sheet_wrapper.dart';
import 'events_overview/events_overview_page.dart';

class AppolloAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  _AppolloAppBarState createState() => _AppolloAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(74.0);
}

class _AppolloAppBarState extends State<AppolloAppBar> {
  @override
  Widget build(BuildContext context) {
    return _buildAppBar();
  }

  Widget _buildAppBar() {
    return AppBar(
      titleSpacing: 0.0,
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: MyTheme.appolloBackgroundColor,
      centerTitle: true,
      toolbarHeight: 74,
      title: Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        width: MyTheme.maxWidth,
        height: widget.preferredSize.height,
        child: Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                  onTap: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                    Navigator.popAndPushNamed(context, EventOverviewPage.routeName,
                        arguments: EventsRepository.instance.events);
                  },
                  child: SvgPicture.asset(
                    AppolloSvgIcon.menuIcon,
                    height: 48,
                  )),
              InkWell(
                onTap: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                  Navigator.popAndPushNamed(context, EventOverviewPage.routeName,
                      arguments: EventsRepository.instance.events);
                },
                child: Text("appollo",
                    style: MyTheme.textTheme.subtitle1.copyWith(
                      fontFamily: "cocon",
                      color: Colors.white,
                      fontSize: 26,
                    )),
              ),
              ValueListenableBuilder(
                  valueListenable: UserRepository.instance.currentUserNotifier,
                  builder: (context, value, child) {
                    return _buildProfileButton();
                  })
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileButton() {
    if (UserRepository.instance.isLoggedIn) {
      return InkWell(
        onTap: () {
          showCupertinoModalBottomSheet(
              context: context,
              backgroundColor: MyTheme.appolloBackgroundColor,
              expand: true,
              builder: (context) => AuthenticationPageWrapper());
        },
        child: CircleAvatar(
          radius: 18,
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
      );
    } else {
      return InkWell(
          onTap: () {
            showCupertinoModalBottomSheet(
                context: context,
                backgroundColor: MyTheme.appolloBackgroundColorLight,
                expand: true,
                builder: (context) => AuthenticationPageWrapper());
          },
          child: Text(
            "Sign In",
            style: MyTheme.textTheme.bodyText1.copyWith(color: MyTheme.appolloGreen),
          ));
    }
  }
}
