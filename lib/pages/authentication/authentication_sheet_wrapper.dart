import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/utilities/svg/icon.dart';

import 'authentication_page.dart';
import 'bloc/authentication_bloc.dart';

class AuthenticationPageWrapper extends StatefulWidget {
  final BuildContext? parentContext;
  final Function(bool)? onAutoAuthenticated;

  const AuthenticationPageWrapper({Key? key, this.parentContext, this.onAutoAuthenticated}) : super(key: key);

  @override
  _AuthenticationPageWrapperState createState() => _AuthenticationPageWrapperState();
}

class _AuthenticationPageWrapperState extends State<AuthenticationPageWrapper> {
  late AuthenticationBloc bloc;

  @override
  void initState() {
    bloc = AuthenticationBloc();
    super.initState();
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: MyTheme.appolloBottomBarColor,
        centerTitle: true,
        leading: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          bloc: bloc,
          builder: (c, state) {
            print(state);
            if (state is StateNewUserEmail) {
              return InkWell(
                onTap: () {
                  bloc.add(EventChangeEmail());
                },
                child: SvgPicture.asset(
                  AppolloSvgIcon.arrowBackOutline,
                  color: MyTheme.appolloWhite,
                  height: 36,
                  width: 36,
                  fit: BoxFit.scaleDown,
                ),
              );
            } else if (state is StateNewUserEmailsConfirmed) {
              return InkWell(
                onTap: () {
                  bloc.add(EventChangeEmail());
                },
                child: SvgPicture.asset(
                  AppolloSvgIcon.arrowBackOutline,
                  color: MyTheme.appolloWhite,
                  height: 36,
                  width: 36,
                  fit: BoxFit.scaleDown,
                ),
              );
            } else if (state is StatePasswordsConfirmed) {
              return InkWell(
                onTap: () {
                  bloc.add(EventChangeEmail());
                },
                child: SvgPicture.asset(
                  AppolloSvgIcon.arrowBackOutline,
                  color: MyTheme.appolloWhite,
                  height: 36,
                  width: 36,
                  fit: BoxFit.scaleDown,
                ),
              );
            } else {
              return SizedBox.shrink();
            }
          },
        ),
        title: Container(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: MyTheme.elementSpacing, vertical: MyTheme.elementSpacing),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Sign up or sign in",
                        style: MyTheme.textTheme.headline5,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Done",
                        style: MyTheme.textTheme.bodyText1!.copyWith(color: MyTheme.appolloGreen),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      body: AuthenticationPage(
        onAutoAuthenticated: widget.onAutoAuthenticated,
        bloc: bloc,
      ),
    );
  }
}
