import 'dart:ui';
import 'dart:html' as js;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webapp/UI/authentication/signUpForm.dart';
import 'package:webapp/UI/eventInfo.dart';
import 'package:webapp/UI/theme.dart';
import 'package:webapp/UI/whyAreYouHere.dart';
import 'package:webapp/model/link_type/advertisementInvite.dart';
import 'package:webapp/model/link_type/birthdayList.dart';
import 'package:webapp/model/link_type/invitation.dart';
import 'package:webapp/model/link_type/link_type.dart';
import 'package:webapp/model/link_type/promoterInvite.dart';
import 'package:webapp/model/user.dart';
import 'package:webapp/pages/event_details/desktop_view_drawer.dart';
import 'package:webapp/pages/event_details/event_details_page.dart';
import 'package:webapp/repositories/ticket_repository.dart';
import 'package:webapp/services/firebase.dart';
import 'package:webapp/services/validator.dart' as val;
import 'package:webapp/utilities/alertGenerator.dart';
import 'package:websafe_svg/websafe_svg.dart';
import 'package:webapp/UI/theme.dart';

import 'bloc/auth_page.dart';
import 'bloc/authentication_bloc.dart';

class AuthenticationPage extends StatefulWidget {
  final LinkType linkType;
  AuthenticationPage(this.linkType);
  @override
  _AuthenticationPageState createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> with TickerProviderStateMixin {
  AuthenticationBloc signUpBloc;

  FormGroup form;

  final int animationTime = 400;

  // Not using a reactive form for the login since we're using custom logic for the email field.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmEmailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confirmPwController = TextEditingController();
  bool _validatePW = false;
  bool _termsAccepted = false;

  int releaseManagerSelected = 0;

  clearData() {
    _emailController.clear();
    _confirmEmailController.clear();
    _pwController.clear();
    _confirmPwController.clear();
    _validatePW = false;
    _termsAccepted = false;
    form.reset();
  }

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
    signUpBloc = AuthenticationBloc(widget.linkType);
    signUpBloc.add(EventPageLoad());
    TicketRepository.instance.incrementLinkOpenedCounter(widget.linkType);
    super.initState();
  }

  @override
  void dispose() {
    signUpBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    MyTheme.maxWidth = screenSize.width < 800 ? screenSize.width : 800;
    MyTheme.cardPadding = getValueForScreenType(context: context, watch: 8, mobile: 8, tablet: 20, desktop: 20);
    return Scaffold(
      endDrawer: BlocProvider.value(
          value: signUpBloc,
          child: DesktopViewDrawer(
            bloc: signUpBloc,
            linkType: widget.linkType,
          )),
      endDrawerEnableOpenDragGesture: false,
      body: Stack(
        children: [
          Positioned(
            width: screenSize.width * 1.01,
            height: screenSize.height * 1.01,
            child: Container(
              width: screenSize.width,
              height: screenSize.height,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.linkType.event.coverImageURL),
                  fit: BoxFit.cover,
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 60.0, sigmaY: 60.0),
                child: Container(
                  width: screenSize.width,
                  height: screenSize.height,
                  decoration: BoxDecoration(color: Colors.grey[900].withOpacity(0.2)),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              constraints: BoxConstraints(maxWidth: MyTheme.maxWidth + 8),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(
                      getValueForScreenType(context: context, desktop: 0, tablet: 0, mobile: 8, watch: 8)),
                  child: Column(
                    children: [
                      Column(
                        children: [
                          // Add some top padding if we show the appbar
                          BlocBuilder<AuthenticationBloc, AuthenticationState>(
                              cubit: signUpBloc,
                              builder: (c, state) {
                                return ResponsiveBuilder(builder: (context, constraints) {
                                  if (state is StateLoggedIn &&
                                      (constraints.deviceScreenType == DeviceScreenType.mobile ||
                                          constraints.deviceScreenType == DeviceScreenType.watch)) {
                                    return SizedBox(height: 66);
                                  } else {
                                    return SizedBox.shrink();
                                  }
                                });
                              }),

                          BlocBuilder<AuthenticationBloc, AuthenticationState>(
                              cubit: signUpBloc,
                              builder: (c, state) {
                                return ResponsiveBuilder(builder: (context, constraints) {
                                  if ((constraints.deviceScreenType == DeviceScreenType.mobile ||
                                      constraints.deviceScreenType == DeviceScreenType.watch)) {
                                    if (state is StateNewUserEmail ||
                                        state is StateNewUserEmailsConfirmed ||
                                        state is StatePasswordsConfirmed) {
                                      return SizedBox.shrink();
                                    } else {
                                      return Column(
                                        children: [
                                          _buildWhyAreYouHere(state),
                                          Container(
                                            child: EventInfoWidget(Axis.vertical, widget.linkType.event),
                                          ).appolloCard.paddingBottom(8),
                                        ],
                                      );
                                    }
                                  } else {
                                    return EventInfoWidget(Axis.horizontal, widget.linkType.event)
                                        .paddingTop(MyTheme.cardPadding);
                                  }
                                });
                              }),

                          // Builds the login functionality
                          BlocConsumer<AuthenticationBloc, AuthenticationState>(
                              cubit: signUpBloc,
                              listener: (c, state) {
                                if (state is StateErrorSignUp) {
                                  String text =
                                      "We couldn't create an account for you, please make sure your password is at least 8 characters long";
                                  if (state.error == SignUpError.UserCancelled) {
                                    text =
                                        "Login pop up closed. Your browser might be blocking the login pop up. Please try again or use a different login method.";
                                  } else {
                                    text = "An error occurred during the signup process, please try again";
                                  }
                                  AlertGenerator.showAlert(
                                      context: context,
                                      title: "Error",
                                      content: text,
                                      buttonText: "Ok",
                                      popTwice: false);
                                } else if (state is StateLoginFailed) {
                                  AlertGenerator.showAlert(
                                      context: context,
                                      title: "Wrong Password",
                                      content: "Your password is incorrect, please try again.",
                                      buttonText: "Ok",
                                      popTwice: false);
                                } else if (state is StateNewSSOUser) {
                                  _emailController.text = state.email;
                                  form.controls["fname"].value = state.firstName;
                                  form.controls["lname"].value = state.lastName;
                                } else if (state is StateLoggedIn &&
                                    (getDeviceType(screenSize) == DeviceScreenType.mobile ||
                                        getDeviceType(screenSize) == DeviceScreenType.watch)) {
                                  Navigator.push(context,
                                          MaterialPageRoute(builder: (context) => EventDetailsPage(widget.linkType)))
                                      .then((value) {
                                    signUpBloc.add(EventPageLoad());
                                  });
                                }
                              },
                              buildWhen: (c, state) {
                                if (state is StateErrorSignUp) {
                                  return false;
                                }
                                return true;
                              },
                              builder: (c, state) {
                                if (state is StateLoggedIn &&
                                        (getDeviceType(screenSize) == DeviceScreenType.mobile ||
                                            getDeviceType(screenSize) == DeviceScreenType.watch) ||
                                    (getDeviceType(screenSize) == DeviceScreenType.tablet ||
                                        getDeviceType(screenSize) == DeviceScreenType.desktop)) {
                                  return SizedBox.shrink();
                                } else {
                                  return Column(
                                    children: [
                                      AnimatedSize(
                                        vsync: this,
                                        duration: Duration(milliseconds: animationTime),
                                        child: Container(
                                          constraints: BoxConstraints(maxWidth: MyTheme.maxWidth + 8),
                                          child: Container(
                                            child: Padding(
                                              padding: EdgeInsets.all(MyTheme.cardPadding),
                                              child: AuthPage(
                                                bloc: signUpBloc,
                                                textTheme: MyTheme.lightTextTheme,
                                              ),
                                            ),
                                          ).appolloCard,
                                        ),
                                      ),
                                    ],
                                  )
                                      .paddingTop(getValueForScreenType(
                                          context: context,
                                          desktop: MyTheme.elementSpacing,
                                          tablet: MyTheme.elementSpacing,
                                          mobile: 0,
                                          watch: 0))
                                      .paddingBottom(getValueForScreenType(
                                          context: context,
                                          desktop: state is StateLoggedIn ? MyTheme.elementSpacing : 0,
                                          tablet: state is StateLoggedIn ? MyTheme.elementSpacing : 0,
                                          mobile: 0,
                                          watch: 0));
                                }
                              }),
                        ],
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      ResponsiveBuilder(builder: (context, constraints) {
                        if ((constraints.deviceScreenType == DeviceScreenType.mobile ||
                            constraints.deviceScreenType == DeviceScreenType.watch)) {
                          return _buildPoweredByAppollo();
                        } else {
                          return SizedBox(
                            height: 60,
                          );
                        }
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(alignment: Alignment.bottomCenter, child: _buildBottomBar(screenSize))
        ],
      ),
    );
  }

/*
  /// Input fields required for sign up
  Widget _buildNewUser(AuthenticationState state, Size screenSize) {
    return SizedBox(
      width: screenSize.width,
      child: Column(
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MyTheme.maxWidth + 8),
            child: Column(
              children: [
                SizedBox(
                  height: getValueForScreenType(
                      context: context, watch: 0, mobile: 0, desktop: MyTheme.elementSpacing, tablet: MyTheme.elementSpacing),
                ),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(MyTheme.cardPadding),
                    child: ReactiveForm(
                        formGroup: form,
                        child: Column(
                          children: [
                            AutoSizeText(
                              "Tell us about yourself",
                              textAlign: TextAlign.center,
                              style: MyTheme.lightTextTheme.headline6,
                            ),
                            SizedBox(
                              height: MyTheme.elementSpacing * 1.5,
                            ),
                            AutoSizeText(
                              "Name",
                              style: MyTheme.lightTextTheme.headline6,
                            ),
                            SizedBox(
                              height: MyTheme.elementSpacing,
                            ),
                            ResponsiveBuilder(builder: (context, constraints) {
                              if (constraints.deviceScreenType == DeviceScreenType.mobile ||
                                  constraints.deviceScreenType == DeviceScreenType.watch) {
                                return Column(
                                  children: [
                                    ReactiveTextField(
                                      formControlName: 'fname',
                                      validationMessages: (control) => {
                                        ValidationMessage.required: 'Please provide a name',
                                      },
                                      decoration: InputDecoration(labelText: "First Name"),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    ReactiveTextField(
                                      formControlName: 'lname',
                                      validationMessages: (control) => {
                                        ValidationMessage.required: 'Please provide a name',
                                      },
                                      decoration: InputDecoration(labelText: "Last Name"),
                                    ),
                                  ],
                                );
                              } else {
                                return SizedBox(
                                  width: MyTheme.maxWidth - MyTheme.cardPadding * 4,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: (MyTheme.maxWidth - MyTheme.cardPadding * 4 - 26) / 2,
                                        child: ReactiveTextField(
                                          formControlName: 'fname',
                                          validationMessages: (control) => {
                                            ValidationMessage.required: 'Please provide a name',
                                          },
                                          decoration: InputDecoration(labelText: "First Name"),
                                        ),
                                      ),
                                      SizedBox(
                                        width: (MyTheme.maxWidth - MyTheme.cardPadding * 4 - 26) / 2,
                                        child: ReactiveTextField(
                                          formControlName: 'lname',
                                          validationMessages: (control) => {
                                            ValidationMessage.required: 'Please provide a name',
                                          },
                                          decoration: InputDecoration(labelText: "Last Name"),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }),
                            SizedBox(
                              height: MyTheme.elementSpacing * 2,
                            ),
                            ResponsiveBuilder(builder: (context, constraints) {
                              if (constraints.deviceScreenType == DeviceScreenType.mobile ||
                                  constraints.deviceScreenType == DeviceScreenType.watch) {
                                return AutoSizeText(
                                  "Date of birth",
                                  style: MyTheme.lightTextTheme.headline6,
                                );
                              } else {
                                return SizedBox(
                                  width: MyTheme.maxWidth,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      AutoSizeText(
                                        "Date of birth",
                                        style: MyTheme.lightTextTheme.headline6,
                                      ),
                                      SizedBox.shrink(),
                                      AutoSizeText(
                                        "Gender",
                                        style: MyTheme.lightTextTheme.headline6,
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }),
                            SizedBox(
                              height: MyTheme.elementSpacing,
                            ),
                            ResponsiveBuilder(builder: (context, constraints) {
                              if (constraints.deviceScreenType == DeviceScreenType.mobile ||
                                  constraints.deviceScreenType == DeviceScreenType.watch) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: (MyTheme.maxWidth - MyTheme.cardPadding * 4) + 8,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: (MyTheme.maxWidth - MyTheme.cardPadding * 4 - 30) / 3,
                                            child: ReactiveTextField(
                                              formControlName: 'dobDay',
                                              keyboardType: TextInputType.number,
                                              validationMessages: (control) => {
                                                ValidationMessage.required: 'Please provide a day',
                                                ValidationMessage.max: 'Please provide a valid day',
                                              },
                                              inputFormatters: [
                                                FilteringTextInputFormatter.digitsOnly,
                                              ],
                                              decoration: InputDecoration(
                                                hintText: "DD",
                                                labelText: 'Day',
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: (MyTheme.maxWidth - MyTheme.cardPadding * 4 - 30) / 3,
                                            child: ReactiveTextField(
                                              formControlName: 'dobMonth',
                                              validationMessages: (control) => {
                                                ValidationMessage.required: 'Please provide a month',
                                                ValidationMessage.max: 'Please provide a valid month',
                                              },
                                              keyboardType: TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter.digitsOnly,
                                              ],
                                              decoration: InputDecoration(
                                                hintText: "MM",
                                                labelText: 'Month',
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: (MyTheme.maxWidth - MyTheme.cardPadding * 4 - 30) / 3,
                                            child: ReactiveTextField(
                                              formControlName: 'dobYear',
                                              validationMessages: (control) => {
                                                ValidationMessage.required: 'Please provide a year',
                                                ValidationMessage.max: 'Please provide a valid year',
                                                ValidationMessage.min: 'Please provide a valid year',
                                              },
                                              keyboardType: TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter.digitsOnly,
                                              ],
                                              decoration: InputDecoration(
                                                hintText: "YYYY",
                                                labelText: 'Year',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: MyTheme.elementSpacing * 2,
                                    ),
                                    AutoSizeText(
                                      "Gender",
                                      style: MyTheme.lightTextTheme.headline6,
                                    ),
                                    SizedBox(
                                      height: MyTheme.elementSpacing,
                                    ),
                                    SizedBox(
                                      width: (MyTheme.maxWidth - MyTheme.cardPadding * 4) + 8,
                                      child: ReactiveDropdownField(
                                        formControlName: 'gender',
                                        decoration: InputDecoration(),
                                        items: [Gender.Female, Gender.Male, Gender.Other].map((e) {
                                          return DropdownMenuItem(
                                            value: e,
                                            child: Text(e.toDisplayString()),
                                          );
                                        }).toList(),
                                      ),
                                    )
                                  ],
                                );
                              } else {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: (MyTheme.maxWidth / 2 - MyTheme.cardPadding * 3) + 8,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: (MyTheme.maxWidth / 2 - MyTheme.cardPadding * 3 - 26) / 3,
                                            child: ReactiveTextField(
                                              formControlName: 'dobDay',
                                              keyboardType: TextInputType.number,
                                              validationMessages: (control) => {
                                                ValidationMessage.required: 'Please provide a day',
                                                ValidationMessage.max: 'Please provide a valid day',
                                              },
                                              inputFormatters: [
                                                FilteringTextInputFormatter.digitsOnly,
                                              ],
                                              decoration: InputDecoration(
                                                hintText: "DD",
                                                labelText: 'Day',
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: (MyTheme.maxWidth / 2 - MyTheme.cardPadding * 3 - 26) / 3,
                                            child: ReactiveTextField(
                                              formControlName: 'dobMonth',
                                              validationMessages: (control) => {
                                                ValidationMessage.required: 'Please provide a month',
                                                ValidationMessage.max: 'Please provide a valid month',
                                              },
                                              keyboardType: TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter.digitsOnly,
                                              ],
                                              decoration: InputDecoration(
                                                hintText: "MM",
                                                labelText: 'Month',
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: (MyTheme.maxWidth / 2 - MyTheme.cardPadding * 3 - 26) / 3,
                                            child: ReactiveTextField(
                                              formControlName: 'dobYear',
                                              validationMessages: (control) => {
                                                ValidationMessage.required: 'Please provide a year',
                                                ValidationMessage.max: 'Please provide a valid year',
                                                ValidationMessage.min: 'Please provide a valid year',
                                              },
                                              keyboardType: TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter.digitsOnly,
                                              ],
                                              decoration: InputDecoration(
                                                hintText: "YYYY",
                                                labelText: 'Year',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: (MyTheme.maxWidth / 2 - MyTheme.cardPadding * 3) + 8,
                                      child: ReactiveDropdownField(
                                        formControlName: 'gender',
                                        decoration: InputDecoration(),
                                        items: [Gender.Female, Gender.Male, Gender.Other].map((e) {
                                          return DropdownMenuItem(
                                            value: e,
                                            child: Text(e.toDisplayString()),
                                          );
                                        }).toList(),
                                      ),
                                    )
                                  ],
                                );
                              }
                            }),
                            SizedBox(
                              height: MyTheme.elementSpacing * 2,
                            ),
                            AutoSizeText(
                              "Terms & Conditions",
                              style: MyTheme.lightTextTheme.headline6,
                            ),
                            SizedBox(
                              height: MyTheme.elementSpacing,
                            ),
                            AutoSizeText(
                              "We require this information to issue your ticket. Please note that providing incorrect information may invalidate you ticket.\n\nWe’ll save this data for you so you’ll only need to provide it once. ",
                              style: MyTheme.lightTextTheme.caption,
                            ),
                            SizedBox(
                              height: MyTheme.elementSpacing,
                            ),
                            SizedBox(
                              width: MyTheme.maxWidth,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                      onTap: () async {
                                        const url = 'https://appollo.io/terms-of-service.html';
                                        if (await canLaunch(url)) {
                                          await launch(url);
                                        } else {
                                          throw 'Could not launch $url';
                                        }
                                      },
                                      child: Text(
                                        "I accept the terms & conditions",
                                        style: TextStyle().copyWith(decoration: TextDecoration.underline),
                                      )),
                                  ReactiveCheckbox(
                                    formControlName: "terms",
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: MyTheme.elementSpacing * 1.5,
                            ),
                            _buildMainButtons(state, screenSize),
                          ],
                        )),
                  ),
                ).appolloCard,
              ],
            ),
          ),
        ],
      ),
    );
  }
  */
  _buildPoweredByAppollo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: MyTheme.elementSpacing,
        ),
        Text(
          "Powered by",
          style: MyTheme.lightTextTheme.caption.copyWith(
              color: Colors.grey[200],
              fontWeight: FontWeight.w300,
              shadows: [BoxShadow(color: Colors.black, blurRadius: 1, spreadRadius: 1)]),
        ),
        Text("appollo",
            style: MyTheme.lightTextTheme.subtitle1.copyWith(
                fontFamily: "cocon",
                color: Colors.white,
                fontSize: 20,
                shadows: [BoxShadow(color: Colors.black, blurRadius: 1, spreadRadius: 1)])),
        SizedBox(
          height: MyTheme.elementSpacing,
        ),
      ],
    );
  }

  Widget _buildWhyAreYouHere(AuthenticationState state) {
    if (widget.linkType is AdvertisementInvite || state is StateNewUserEmail || state is StateNewUserEmailsConfirmed) {
      return Container();
    }

    String text = "";

    if (widget.linkType is PromoterInvite) {
      PromoterInvite invitation = widget.linkType;
      text = "${invitation.promoter.firstName} ${invitation.promoter.lastName} has invited you to an event.";
    } else if (widget.linkType is Booking) {
      Booking invitation = widget.linkType;
      text =
          "${invitation.promoter.firstName} ${invitation.promoter.lastName} has invited you to their birthday party.";
    }

    return WhyAreYouHere(text).paddingBottom(8);
  }

  Widget _buildBottomBar(Size screenSize) {
    return ResponsiveBuilder(builder: (context, constraints) {
      if (constraints.deviceScreenType == DeviceScreenType.mobile ||
          constraints.deviceScreenType == DeviceScreenType.watch) {
        return SizedBox.shrink();
      } else {
        String invitationText = "Get your tickets here";
        if (widget.linkType is Booking) {
          invitationText =
              "You've been invited to ${(widget.linkType as Booking).promoter.firstName} ${(widget.linkType as Booking).promoter.lastName}'s booking";
        } else if (widget.linkType is Invitation) {
          invitationText =
              "You've been invited by ${(widget.linkType as Invitation).promoter.firstName} ${(widget.linkType as Invitation).promoter.lastName}";
        }
        return Container(
          width: screenSize.width,
          height: 50,
          decoration: ShapeDecoration(
              color: MyTheme.appolloPurple,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)))),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: MyTheme.cardPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(invitationText),
                SizedBox(
                  height: 32,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    padding: EdgeInsets.symmetric(horizontal: MyTheme.cardPadding),
                    color: MyTheme.appolloYellow,
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                    child: Text("GET YOUR TICKET"),
                  ),
                )
              ],
            ),
          ),
        );
      }
    });
  }
}
