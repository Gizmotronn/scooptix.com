import 'dart:typed_data';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/appollo/appollo_progress_indicator.dart';
import 'package:ticketapp/UI/widgets/buttons/apollo_button.dart';
import 'package:ticketapp/repositories/user_repository.dart';
import 'package:ticketapp/services/image_util.dart';
import 'login_and_signup_page.dart';
import 'bloc/authentication_bloc.dart';
import 'package:ticketapp/pages/authentication/profile/bloc/profile_bloc.dart' as profile;
import 'package:firebase_auth/firebase_auth.dart' as auth;

class AuthenticationPage extends StatefulWidget {
  static const String routeName = '/auth';
  final Function onAutoAuthenticated;
  final AuthenticationBloc bloc; // HACK: Allows the auth sheet wrapper access to the bloc state

  const AuthenticationPage({Key key, this.onAutoAuthenticated, this.bloc}) : super(key: key);
  @override
  _AuthenticationPageState createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> with TickerProviderStateMixin {
  profile.ProfileBloc profileBloc;
  AuthenticationBloc signUpBloc;

  final int animationTime = 400;

  @override
  void initState() {
    if (widget.bloc != null) {
      signUpBloc = widget.bloc;
    } else {
      signUpBloc = AuthenticationBloc();
    }
    signUpBloc.add(EventPageLoad());
    super.initState();
  }

  @override
  void dispose() {
    if (profileBloc != null) {
      profileBloc.close();
      profileBloc = null;
    }
    signUpBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: MyTheme.elementSpacing),
      // height: screenSize.height - 58,
      child: LayoutBuilder(builder: (context, constraints) {
        return SizedBox(
          height: constraints.maxHeight,
          child: BlocConsumer<AuthenticationBloc, AuthenticationState>(
              cubit: signUpBloc,
              listener: (c, state) {
                if (state is StateAutoLoggedIn) {
                  if (widget.onAutoAuthenticated != null) {
                    widget.onAutoAuthenticated(true);
                  }
                }
                if (state is StateLoggedIn) {
                  if (widget.onAutoAuthenticated != null) {
                    widget.onAutoAuthenticated(false);
                  }
                  if (profileBloc == null) {
                    profileBloc = profile.ProfileBloc();
                  }
                }
              },
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
                              style: Theme.of(context).textTheme.headline2.copyWith(color: MyTheme.appolloGreen),
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
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    Uint8List imageData = await ImageUtil.pickImage();
                                    if (imageData != null) {
                                      profileBloc.add(profile.EventUploadProfileImage(imageData));
                                    }
                                  },
                                  child: SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: BlocBuilder<profile.ProfileBloc, profile.ProfileState>(
                                        cubit: profileBloc,
                                        builder: (context, state) {
                                          if (state is profile.StateInitial) {
                                            return CircleAvatar(
                                              radius: 50,
                                              backgroundImage: ExtendedImage.network(
                                                  UserRepository.instance.currentUser().profileImageURL ?? "",
                                                  cache: true,
                                                  fit: BoxFit.cover, loadStateChanged: (ExtendedImageState state) {
                                                switch (state.extendedImageLoadState) {
                                                  case LoadState.loading:
                                                    return Container(
                                                      color: Colors.white,
                                                    );
                                                  case LoadState.completed:
                                                    return state.completedWidget;
                                                  default:
                                                    return Container(
                                                      color: Colors.white,
                                                    );
                                                }
                                              }).image,
                                            );
                                          } else {
                                            return Center(child: AppolloProgressIndicator());
                                          }
                                        }),
                                  ),
                                ),
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
                              ],
                            ).paddingBottom(MyTheme.elementSpacing * 2),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: AppolloButton.regularButton(
                                onTap: () async {
                                  await auth.FirebaseAuth.instance.signOut();
                                  UserRepository.instance.dispose();
                                  signUpBloc.add(EventLogout());
                                  Navigator.pop(context);
                                },
                                fill: true,
                                child: Text(
                                  "Logout",
                                  style: MyTheme.textTheme.button.copyWith(color: MyTheme.appolloBackgroundColor),
                                ),
                              ),
                            ),
                          ],
                        ).paddingBottom(MyTheme.elementSpacing),
                      ),
                    ],
                  );
                } else {
                  return SizedBox(
                    width: MyTheme.drawerSize,
                    child: LoginAndSignupPage(
                      bloc: signUpBloc,
                    ),
                  );
                }
              }).paddingTop(MyTheme.cardPadding),
        );
      }),
    );
  }
}
