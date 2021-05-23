import 'package:flutter/material.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/pages/authentication/authentication_drawer.dart';
import 'package:ticketapp/repositories/user_repository.dart';

import '../../main.dart';
import 'my_tickets_page.dart';

class MyTicketsDrawer extends StatefulWidget {
  MyTicketsDrawer._();
  static openMyTicketsDrawer() {
    if (!UserRepository.instance.isLoggedIn) {
      WrapperPage.endDrawer.value = AuthenticationDrawer(
        onAutoAuthenticated: () {
          WrapperPage.endDrawer.value = MyTicketsDrawer._();
          WrapperPage.mainScaffold.currentState.openEndDrawer();
        },
      );
      WrapperPage.mainScaffold.currentState.openEndDrawer();
    } else {
      WrapperPage.endDrawer.value = MyTicketsDrawer._();
      WrapperPage.mainScaffold.currentState.openEndDrawer();
    }
  }

  @override
  _MyTicketsDrawerState createState() => _MyTicketsDrawerState();
}

class _MyTicketsDrawerState extends State<MyTicketsDrawer> {
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
                Navigator.pop(WrapperPage.mainScaffold.currentContext);
              },
              child: Icon(
                Icons.close,
                size: 34,
                color: MyTheme.appolloRed,
              ),
            ),
          ),
          SizedBox(
            height: screenSize.height - 34,
            child: Navigator(
                onGenerateRoute: (_) => MaterialPageRoute(
                    builder: (sheetContext) => MyTicketsPage(
                          parentContext: sheetContext,
                        ))),
          ),
        ],
      ),
    );
  }
}
