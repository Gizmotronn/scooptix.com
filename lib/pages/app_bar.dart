import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/appollo/appollo_bottom_sheet.dart';
import 'package:ticketapp/UI/widgets/scooptix_logo.dart';
import 'package:ticketapp/repositories/events_repository.dart';
import 'package:ticketapp/repositories/user_repository.dart';
import 'package:ticketapp/UI/icons.dart';
import 'authentication/authentication_sheet_wrapper.dart';
import 'events_overview/events_overview_page.dart';

class AppolloAppBar extends StatefulWidget {
  final Color? backgroundColor;

  const AppolloAppBar({Key? key, this.backgroundColor}) : super(key: key);
  @override
  _AppolloAppBarState createState() => _AppolloAppBarState();

  Size get preferredSize => Size.fromHeight(MyTheme.appBarHeight);
}

class _AppolloAppBarState extends State<AppolloAppBar> {
  @override
  Widget build(BuildContext context) {
    return _buildAppBar();
  }

  Widget _buildAppBar() {
    return Container(
      color: widget.backgroundColor ?? MyTheme.appolloBackgroundColor,
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
                      arguments: EventsRepository.instance.upcomingPublicEvents);
                },
                child: SvgPicture.asset(
                  AppolloIcons.menuIcon,
                  height: 48,
                )),
            InkWell(
              onTap: () {
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.popAndPushNamed(context, EventOverviewPage.routeName,
                    arguments: EventsRepository.instance.upcomingPublicEvents);
              },
              child: ScooptixLogo(),
            ),
            ValueListenableBuilder(
                valueListenable: UserRepository.instance.currentUserNotifier,
                builder: (context, value, child) {
                  return _buildProfileButton();
                })
          ],
        ),
      ),
    );
  }

  Widget _buildProfileButton() {
    if (UserRepository.instance.isLoggedIn) {
      return InkWell(
        onTap: () {
          showAppolloModalBottomSheet(
              context: context,
              backgroundColor: MyTheme.appolloBackgroundColor,
              expand: true,
              settings: RouteSettings(name: "authentication_sheet"),
              builder: (context) => AuthenticationPageWrapper());
        },
        child: CircleAvatar(
          radius: 18,
          backgroundImage: ExtendedImage.network(UserRepository.instance.currentUser()!.profileImageURL,
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
            showAppolloModalBottomSheet(
                context: context,
                backgroundColor: MyTheme.appolloBackgroundColorLight,
                expand: true,
                settings: RouteSettings(name: "authentication_sheet"),
                builder: (context) => AuthenticationPageWrapper());
          },
          child: Text(
            "Sign In",
            style: MyTheme.textTheme.bodyText1!.copyWith(color: MyTheme.appolloGreen),
          ));
    }
  }
}
