import 'package:flutter/material.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/appollo/appollo_bottom_sheet.dart';
import 'package:ticketapp/pages/authentication/authentication_sheet_wrapper.dart';
import 'package:ticketapp/repositories/user_repository.dart';
import '../../../main.dart';
import 'reward_center_page.dart';

class RewardCenterSheet extends StatefulWidget {
  RewardCenterSheet._();

  /// Makes sure the user is logged in before opening the My Ticket Sheet
  static openRewardCenterSheet() {
    if (UserRepository.instance.isLoggedIn) {
      showAppolloModalBottomSheet(
          context: WrapperPage.navigatorKey.currentContext!,
          backgroundColor: MyTheme.scoopBackgroundColorLight,
          expand: true,
          settings: RouteSettings(name: "reward_center_sheet"),
          builder: (context) => RewardCenterSheet._());
    } else {
      showAppolloModalBottomSheet(
          context: WrapperPage.navigatorKey.currentContext!,
          backgroundColor: MyTheme.scoopBackgroundColorLight,
          expand: true,
          builder: (context) => AuthenticationPageWrapper(
                onAutoAuthenticated: (autoLoggedIn) {
                  Navigator.pop(WrapperPage.navigatorKey.currentContext!);
                  showAppolloModalBottomSheet(
                      context: WrapperPage.navigatorKey.currentContext!,
                      backgroundColor: MyTheme.scoopBackgroundColorLight,
                      expand: true,
                      settings: RouteSettings(name: "reward_center_sheet"),
                      builder: (context) => RewardCenterSheet._());
                },
              ));
    }
  }

  @override
  _RewardCenterSheetState createState() => _RewardCenterSheetState();
}

class _RewardCenterSheetState extends State<RewardCenterSheet> {
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: MyTheme.scoopCardColorLight,
          automaticallyImplyLeading: false,
          title: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: MyTheme.elementSpacing, vertical: MyTheme.elementSpacing),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox.shrink(),
                    Text(
                      "Reward Center",
                      style: MyTheme.textTheme.headline5,
                    ),
                    Text(
                      "Done",
                      style: MyTheme.textTheme.bodyText1!.copyWith(color: MyTheme.scoopGreen),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: MyTheme.elementSpacing),
          height: screenSize.height,
          child: RewardCenterPage(),
        ));
  }
}
