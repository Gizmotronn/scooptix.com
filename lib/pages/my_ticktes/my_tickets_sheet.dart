import 'package:flutter/material.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/appollo/appollo_bottom_sheet.dart';
import 'package:ticketapp/main.dart';
import 'package:ticketapp/pages/authentication/authentication_sheet_wrapper.dart';
import 'package:ticketapp/repositories/user_repository.dart';
import 'my_tickets_page.dart';

class MyTicketsSheet extends StatefulWidget {
  MyTicketsSheet._();

  /// Makes sure the user is logged in before opening the My Ticket Sheet
  static openMyTicketsSheet() {
    if (UserRepository.instance.isLoggedIn) {
      showAppolloModalBottomSheet(
          context: WrapperPage.navigatorKey.currentContext,
          backgroundColor: MyTheme.appolloBackgroundColor,
          expand: true,
          builder: (context) => MyTicketsSheet._());
    } else {
      showAppolloModalBottomSheet(
          context: WrapperPage.navigatorKey.currentContext,
          backgroundColor: MyTheme.appolloBackgroundColor,
          expand: true,
          builder: (context) => AuthenticationPageWrapper(
                onAutoAuthenticated: (autoLoggedIn) {
                  Navigator.pop(WrapperPage.navigatorKey.currentContext);
                  showAppolloModalBottomSheet(
                      context: WrapperPage.navigatorKey.currentContext,
                      backgroundColor: MyTheme.appolloBackgroundColor,
                      expand: true,
                      builder: (context) => MyTicketsSheet._());
                },
              ));
    }
  }

  @override
  _MyTicketsSheetState createState() => _MyTicketsSheetState();
}

class _MyTicketsSheetState extends State<MyTicketsSheet> {
  @override
  Widget build(BuildContext context) {
    return Navigator(onGenerateRoute: (_) {
      return MaterialPageRoute(builder: (sheetContext) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: MyTheme.appolloCardColorLight,
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
                        "My Tickets",
                        style: MyTheme.textTheme.headline5,
                      ),
                      Text(
                        "Done",
                        style: MyTheme.textTheme.bodyText1.copyWith(color: MyTheme.appolloGreen),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: MyTicketsPage(parentContext: sheetContext),
        );
      });
    });
  }
}
