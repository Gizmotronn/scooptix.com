import 'package:flutter/material.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/pages/authentication/authentication_drawer.dart';
import 'package:ticketapp/pages/reward_center/reward_center_page.dart';
import 'package:ticketapp/repositories/user_repository.dart';

import '../../main.dart';

class RewardCenterDrawer extends StatefulWidget {
  RewardCenterDrawer._();
  static openRewardCenterDrawer() {
    if (!UserRepository.instance.isLoggedIn) {
      WrapperPage.endDrawer.value = AuthenticationDrawer(
        onAutoAuthenticated: () {
          WrapperPage.endDrawer.value = RewardCenterDrawer._();
          WrapperPage.mainScaffold.currentState!.openEndDrawer();
        },
      );
      WrapperPage.mainScaffold.currentState!.openEndDrawer();
    } else {
      WrapperPage.endDrawer.value = RewardCenterDrawer._();
      WrapperPage.mainScaffold.currentState!.openEndDrawer();
    }
  }

  @override
  _RewardCenterDrawerState createState() => _RewardCenterDrawerState();
}

class _RewardCenterDrawerState extends State<RewardCenterDrawer> {
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Container(
      width: MyTheme.drawerSize,
      height: screenSize.height,
      decoration: ShapeDecoration(
          color: MyTheme.appolloBackgroundColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)))),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: () {
                Navigator.pop(WrapperPage.mainScaffold.currentContext!);
              },
              child: Icon(
                Icons.close,
                size: 34,
                color: MyTheme.appolloRed,
              ),
            ),
          ),
          SizedBox(
            height: screenSize.height - 58,
            child: RewardCenterPage().paddingAll(MyTheme.elementSpacing),
          ),
        ],
      ),
    );
  }
}
