import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/model/link_type/link_type.dart';
import 'package:ticketapp/repositories/user_repository.dart';

import 'bloc/authentication_bloc.dart';
import 'login_and_signup_page.dart';

class AuthView extends StatelessWidget {
  final AuthenticationBloc bloc;
  final LinkType linkType;

  const AuthView({Key key, this.bloc, this.linkType}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
        cubit: bloc,
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
                    width: MyTheme.drawerSize / 1.7,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      SizedBox(
                        width: MyTheme.drawerSize / 1.7,
                        child: AutoSizeText(
                          "${UserRepository.instance.currentUser.firstname} ${UserRepository.instance.currentUser.lastname}",
                          maxLines: 1,
                          style: MyTheme.darkTextTheme.headline6,
                        ),
                      ),
                      SizedBox(
                        width: MyTheme.drawerSize / 1.7,
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
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                        side: BorderSide(color: MyTheme.appolloPurple, width: 1.1),
                      ),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
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
              Text("Event Summary", style: MyTheme.darkTextTheme.headline6).paddingBottom(MyTheme.elementSpacing * 0.5),
              // Text(
              //   linkType.event.name,
              //   style: MyTheme.darkTextTheme.subtitle2,
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          //             AutoSizeText(
                          //               DateFormat.yMMMMd().format(linkType.event.date),
                          //               style: MyTheme.darkTextTheme.bodyText2,
                          //             ).paddingBottom(8),
                          //             if (linkType.event.endTime != null)
                          //               AutoSizeText(
                          //                 "${DateFormat.jm().format(linkType.event.date)} - ${DateFormat.jm().format(linkType.event.endTime)} (${linkType.event.endTime.difference(linkType.event.date).inHours} Hours)",
                          //                 style: MyTheme.darkTextTheme.bodyText2,
                          //               ).paddingBottom(8),
                          //             if (linkType.event.endTime == null)
                          //               AutoSizeText(
                          //                 "${DateFormat.jm().format(linkType.event.date)} ",
                          //                 style: MyTheme.darkTextTheme.bodyText2,
                          //               ).paddingBottom(8),
                          //             AutoSizeText(
                          //               linkType.event.address ?? linkType.event.venueName,
                          //               style: MyTheme.darkTextTheme.bodyText2,
                          //             ),
                          //           ],
                          //         ),
                          //       )
                          //     ],
                          //   ).paddingBottom(MyTheme.elementSpacing * 2),
                          // ),
                          // linkType is MemberInvite &&
                          //         (linkType as MemberInvite).promoter.docId ==
                          //             UserRepository.instance.currentUser.firebaseUserID
                          //     ? Center(
                          //         child: Text("You can't invite yourself to this event", style: MyTheme.darkTextTheme.bodyText2))
                          //     : TicketPage(
                          //         linkType,
                          //         forwardToPayment: true,
                          //       ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ]);
          } else {
            return SizedBox(
              width: MyTheme.drawerSize,
              child: LoginAndSignupPage(
                textTheme: MyTheme.darkTextTheme,
                bloc: bloc,
              ),
            );
          }
        }).paddingTop(MyTheme.cardPadding);
  }
}
