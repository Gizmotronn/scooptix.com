import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/main.dart';
import 'package:ticketapp/pages/authentication/authentication_page.dart';
import 'package:ticketapp/pages/my_ticktes/bloc/my_tickets_bloc.dart';
import 'package:ticketapp/repositories/user_repository.dart';

class MyTicketsSheet extends StatefulWidget {
  MyTicketsSheet._();

  /// Makes sure the user is logged in before opening the My Ticket Sheet
  static openMyTicketsSheet() {
    if (UserRepository.instance.isLoggedIn) {
      showCupertinoModalBottomSheet(
          context: WrapperPage.navigatorKey.currentContext,
          backgroundColor: MyTheme.appolloBackgroundColor,
          expand: true,
          builder: (context) => MyTicketsSheet._());
    } else {
      showCupertinoModalBottomSheet(
          context: WrapperPage.navigatorKey.currentContext,
          backgroundColor: MyTheme.appolloBackgroundColor,
          expand: true,
          builder: (context) => AuthenticationPage(
                onAutoAuthenticated: (autoLoggedIn) {
                  Navigator.pop(WrapperPage.navigatorKey.currentContext);
                  showCupertinoModalBottomSheet(
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
  MyTicketsBloc bloc;

  @override
  void initState() {
    bloc = MyTicketsBloc();
    bloc.add(EventLoadMyTickets());
    super.initState();
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /*
    * To push a new page use
    *  Navigator.push(
            sheetContext,
            MaterialPageRoute(
                builder: (c) => NewPage()));
    *
    * */
    return Navigator(onGenerateRoute: (_) {
      return MaterialPageRoute(builder: (sheetContext) {
        return Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: MyTheme.appolloCardColor2,
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
                          "Order Summary",
                          style: MyTheme.lightTextTheme.headline5,
                        ),
                        Text(
                          "Close",
                          style: MyTheme.lightTextTheme.bodyText1.copyWith(color: MyTheme.appolloGreen),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            body: Container(
              color: MyTheme.appolloGreen,
            ));
      });
    });
  }
}
