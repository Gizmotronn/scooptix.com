import 'package:flutter/material.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/main.dart';
import 'package:ticketapp/pages/authentication/authentication_page.dart';

/// In the desktop view, most of the functionality is displayed in the end drawer.
class AuthenticationDrawer extends StatefulWidget {
  final Function()? onAutoAuthenticated;
  const AuthenticationDrawer({Key? key, this.onAutoAuthenticated}) : super(key: key);

  @override
  _AuthenticationDrawerState createState() => _AuthenticationDrawerState();
}

class _AuthenticationDrawerState extends State<AuthenticationDrawer> {
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
            child: AuthenticationPage(
              onAutoAuthenticated: (autoLoggedIn) {
                if (widget.onAutoAuthenticated != null) {
                  widget.onAutoAuthenticated!();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
