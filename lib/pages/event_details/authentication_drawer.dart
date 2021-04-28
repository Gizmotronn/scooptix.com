import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/main.dart';
import 'package:ticketapp/pages/authentication/bloc/authentication_bloc.dart';
import 'package:ticketapp/pages/authentication/login_and_signup_page.dart';
import 'package:ticketapp/repositories/user_repository.dart';

/// In the desktop view, most of the functionality is displayed in the end drawer.
class AuthenticationDrawer extends StatefulWidget {
  const AuthenticationDrawer({Key key}) : super(key: key);
  // Used to sign in current user session
  // ignore: close_sinks
  static AuthenticationBloc bloc = AuthenticationBloc();

  @override
  _AuthenticationDrawerState createState() => _AuthenticationDrawerState();
}

class _AuthenticationDrawerState extends State<AuthenticationDrawer> {
  AuthenticationBloc bloc;
  @override
  void initState() {
    bloc = AuthenticationDrawer.bloc;
    bloc.add(EventPageLoad());
    super.initState();
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

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
          ).paddingTop(16).paddingRight(16).paddingTop(8),
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: MyTheme.cardPadding),
              constraints: BoxConstraints(minHeight: screenSize.height * 0.9),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BlocBuilder<AuthenticationBloc, AuthenticationState>(
                      cubit: bloc,
                      builder: (c, state) {
                        if (state is StateLoggedIn) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: MyTheme.drawerSize,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Welcome Back",
                                      style: Theme.of(context).textTheme.headline4,
                                    ).paddingBottom(MyTheme.elementSpacing),
                                    /*  InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Icon(
                                        Icons.close,
                                        size: 34,
                                        color: Colors.grey,
                                      )),
                                      */
                                  ],
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: MyTheme.drawerSize / 1.7,
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      SizedBox(
                                        width: MyTheme.drawerSize / 1.7,
                                        child: AutoSizeText(
                                          "${UserRepository.instance.currentUser().firstname} ${UserRepository.instance.currentUser().lastname}",
                                          maxLines: 1,
                                          style: Theme.of(context).textTheme.headline6,
                                        ),
                                      ),
                                      SizedBox(
                                        width: MyTheme.drawerSize / 1.7,
                                        child: AutoSizeText(
                                          "${UserRepository.instance.currentUser().email}",
                                          maxLines: 1,
                                          style: Theme.of(context).textTheme.bodyText2,
                                        ),
                                      ),
                                    ]),
                                  ),
                                  SizedBox(
                                    width: 106,
                                    height: 34,
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        shape:
                                            RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                                        side: BorderSide(color: MyTheme.appolloPurple, width: 1.1),
                                      ),
                                      onPressed: () async {
                                        await auth.FirebaseAuth.instance.signOut();
                                        UserRepository.instance.dispose();
                                        bloc.add(EventLogout());
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        "Logout",
                                        style: MyTheme.lightTextTheme.button.copyWith(color: MyTheme.appolloPurple),
                                      ),
                                    ),
                                  )
                                ],
                              ).paddingBottom(MyTheme.elementSpacing * 2),
                            ],
                          );
                        } else {
                          return SizedBox(
                            width: MyTheme.drawerSize,
                            child: LoginAndSignupPage(
                              textTheme: MyTheme.lightTextTheme,
                              bloc: bloc,
                            ),
                          );
                        }
                      }).paddingTop(MyTheme.cardPadding),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Events Powered By", style: MyTheme.darkTextTheme.bodyText2.copyWith(color: Colors.grey))
                          .paddingRight(4),
                      Text("appollo",
                          style: MyTheme.darkTextTheme.subtitle1.copyWith(
                            fontFamily: "cocon",
                            color: MyTheme.appolloPurple,
                            fontSize: 18,
                          ))
                    ],
                  ).paddingBottom(MyTheme.elementSpacing).paddingTop(MyTheme.elementSpacing),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
