import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/model/link_type/link_type.dart';
import 'package:ticketapp/pages/authentication/bloc/authentication_bloc.dart';
import 'package:ticketapp/pages/authentication/login_and_signup_page.dart';
import 'package:ticketapp/repositories/user_repository.dart';

/// In the desktop view, most of the functionality is displayed in the end drawer.
class DesktopViewDrawer extends StatefulWidget {
  final AuthenticationBloc bloc;
  final LinkType linkType;

  const DesktopViewDrawer({Key key, @required this.bloc, @required this.linkType}) : super(key: key);

  @override
  _DesktopViewDrawerState createState() => _DesktopViewDrawerState();
}

class _DesktopViewDrawerState extends State<DesktopViewDrawer> {
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
              onTap: () => Navigator.pop(context),
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
                      cubit: widget.bloc,
                      builder: (c, state) {
                        if (state is StateLoggedIn) {
                          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                                      side: BorderSide(color: MyTheme.appolloPurple, width: 1.1),
                                    ),
                                    onPressed: () async {
                                      await auth.FirebaseAuth.instance.signOut();
                                      UserRepository.instance.dispose();
                                      widget.bloc.add(EventLogout());
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
                            Text("Event Summary", style: Theme.of(context).textTheme.headline6)
                                .paddingBottom(MyTheme.elementSpacing * 0.5),
                            // Text(
                            //   linkType.event.name,
                            //   style: Theme.of(context).textTheme.subtitle2,
                            // ).paddingBottom(8),
                            SizedBox(
                              width: MyTheme.drawerSize,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Date:",
                                        style: Theme.of(context).textTheme.subtitle2,
                                      ).paddingBottom(8),
                                      Text(
                                        "Duration:",
                                        style: Theme.of(context).textTheme.subtitle2,
                                      ).paddingBottom(8),
                                      Text(
                                        "Location:",
                                        style: Theme.of(context).textTheme.subtitle2,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: MyTheme.elementSpacing,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        /*  AutoSizeText(
                                            DateFormat.yMMMMd().format(linkType.event.date),
                                            style: Theme.of(context).textTheme.bodyText2,
                                          ).paddingBottom(8),
                                          if (linkType.event.endTime != null)
                                            AutoSizeText(
                                              "${DateFormat.jm().format(linkType.event.date)} - ${DateFormat.jm().format(linkType.event.endTime)} (${linkType.event.endTime.difference(linkType.event.date).inHours} Hours)",
                                              style: Theme.of(context).textTheme.bodyText2,
                                            ).paddingBottom(8),
                                          if (linkType.event.endTime == null)
                                            AutoSizeText(
                                              "${DateFormat.jm().format(linkType.event.date)} ",
                                              style: Theme.of(context).textTheme.bodyText2,
                                            ).paddingBottom(8),
                                          AutoSizeText(
                                            linkType.event.address ?? linkType.event.venueName,
                                            style: Theme.of(context).textTheme.bodyText2,
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ).paddingBottom(MyTheme.elementSpacing * 2),
                              ),
                              linkType is MemberInvite &&
                                      (linkType as MemberInvite).promoter.docId ==
                                          UserRepository.instance.currentUser.firebaseUserID
                                  ? Center(
                                      child: Text("You can't invite yourself to this event", style: Theme.of(context).textTheme.bodyText2))
                                  : TicketPage(
                                      linkType,
                                      forwardToPayment: true,
                                    ))}),*/
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            widget.linkType is MemberInvite &&
                                    (widget.linkType as MemberInvite).promoter.docId ==
                                        UserRepository.instance.currentUser().firebaseUserID
                                ? Center(
                                    child: Text("You can't invite yourself to this event",
                                        style: MyTheme.darkTextTheme.bodyText2))
                                : TicketPage(
                                    widget.linkType,
                                    forwardToPayment: true,
                                  ),
                          ],
                        );
                      } else {
                        return SizedBox(
                          width: MyTheme.drawerSize,
                          child: LoginAndSignupPage(
                            textTheme: MyTheme.darkTextTheme,
                            bloc: widget.bloc,
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
        ],
      ),
    );
  }
}
