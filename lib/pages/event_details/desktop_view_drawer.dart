import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:webapp/UI/theme.dart';
import 'package:webapp/model/link_type/link_type.dart';
import 'package:webapp/model/user.dart';
import 'package:webapp/pages/ticket/ticket_page.dart';
import 'package:webapp/pages/authentication/bloc/auth_page.dart';
import 'package:webapp/pages/authentication/bloc/authentication_bloc.dart';
import 'package:webapp/repositories/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class DesktopViewDrawer extends StatefulWidget {
  final AuthenticationBloc bloc;
  final LinkType linkType;

  const DesktopViewDrawer({Key key, @required this.bloc, @required this.linkType}) : super(key: key);

  @override
  _DesktopViewDrawerState createState() => _DesktopViewDrawerState();
}

class _DesktopViewDrawerState extends State<DesktopViewDrawer> {
  bool _termsAccepted = false;
  FormGroup form;
  final double drawerWidth = 500;

  @override
  void initState() {
    form = FormGroup({
      'fname': FormControl(validators: [Validators.required]),
      'lname': FormControl(validators: [Validators.required]),
      'dobDay': FormControl<int>(validators: [Validators.required, Validators.max(31)]),
      'dobMonth': FormControl<int>(validators: [Validators.required, Validators.max(12)]),
      'dobYear': FormControl<int>(validators: [Validators.required, Validators.max(2009), Validators.min(1900)]),
      'gender': FormControl<Gender>(validators: [Validators.required], value: Gender.Female),
      'terms': FormControl<bool>(validators: [Validators.equals(true)], value: _termsAccepted),
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Theme(
      data: MyTheme.theme.copyWith(
          textTheme: MyTheme.darkTextTheme,
          canvasColor: MyTheme.appolloWhite,
          inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(),
              hintStyle: MyTheme.darkTextTheme.bodyText2,
              labelStyle: MyTheme.darkTextTheme.bodyText1,
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF707070).withAlpha(80))))),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: MyTheme.cardPadding * 1.5),
        width: drawerWidth,
        height: screenSize.height,
        decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)))),
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(minHeight: screenSize.height),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BlocBuilder<AuthenticationBloc, AuthenticationState>(
                    cubit: widget.bloc,
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
                                    style: MyTheme.darkTextTheme.headline4,
                                  ).paddingBottom(MyTheme.elementSpacing),
                                  InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Icon(
                                        Icons.close,
                                        size: 34,
                                        color: Colors.grey,
                                      )),
                                ],
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: drawerWidth / 1.7,
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    SizedBox(
                                      width: drawerWidth / 1.7,
                                      child: AutoSizeText(
                                        "${UserRepository.instance.currentUser.firstname} ${UserRepository.instance.currentUser.lastname}",
                                        maxLines: 1,
                                        style: MyTheme.darkTextTheme.headline6,
                                      ),
                                    ),
                                    SizedBox(
                                      width: drawerWidth / 1.7,
                                      child: AutoSizeText(
                                        "${UserRepository.instance.currentUser.email}",
                                        maxLines: 1,
                                        style: MyTheme.darkTextTheme.bodyText2,
                                      ),
                                    ),
                                  ]),
                                ),
                                SizedBox(
                                  width: 106,
                                  height: 34,
                                  child: OutlineButton(
                                    borderSide: BorderSide(color: MyTheme.appolloPurple, width: 1.1),
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
                            Text("Event Summary", style: MyTheme.darkTextTheme.headline6)
                                .paddingBottom(MyTheme.elementSpacing * 0.5),
                            Text(
                              widget.linkType.event.name,
                              style: MyTheme.darkTextTheme.subtitle2,
                            ).paddingBottom(8),
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Date:",
                                      style: MyTheme.darkTextTheme.subtitle2,
                                    ).paddingBottom(8),
                                    Text(
                                      "Duration:",
                                      style: MyTheme.darkTextTheme.subtitle2,
                                    ).paddingBottom(8),
                                    Text(
                                      "Location:",
                                      style: MyTheme.darkTextTheme.subtitle2,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: MyTheme.elementSpacing,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      DateFormat.yMMMMd().format(widget.linkType.event.date),
                                      style: MyTheme.darkTextTheme.bodyText2,
                                    ).paddingBottom(8),
                                    if (widget.linkType.event.endTime != null)
                                      Text(
                                        "${DateFormat.jm().format(widget.linkType.event.date)} - ${DateFormat.jm().format(widget.linkType.event.endTime)} (${widget.linkType.event.endTime.difference(widget.linkType.event.date).inHours} Hours)",
                                        style: MyTheme.darkTextTheme.bodyText2,
                                      ).paddingBottom(8),
                                    if (widget.linkType.event.endTime == null)
                                      Text(
                                        "${DateFormat.jm().format(widget.linkType.event.date)} ",
                                        style: MyTheme.darkTextTheme.bodyText2,
                                      ).paddingBottom(8),
                                    Text(
                                      widget.linkType.event.address ?? widget.linkType.event.venueName,
                                      style: MyTheme.darkTextTheme.bodyText2,
                                    ),
                                  ],
                                )
                              ],
                            ).paddingBottom(MyTheme.elementSpacing * 2),
                            TicketPage(widget.linkType),
                          ],
                        );
                      } else {
                        return SizedBox(
                          width: MyTheme.drawerSize,
                          child: AuthPage(
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
        ),
      ),
    );
  }
}
