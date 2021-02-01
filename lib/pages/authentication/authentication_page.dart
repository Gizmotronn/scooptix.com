import 'dart:ui';
import 'dart:html' as js;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:webapp/UI/theme.dart';
import 'package:webapp/model/link_type/advertisementInvite.dart';
import 'package:webapp/model/link_type/birthdayList.dart';
import 'package:webapp/model/link_type/link_type.dart';
import 'package:webapp/model/link_type/promoterInvite.dart';
import 'package:webapp/model/user.dart';
import 'package:webapp/pages/accept_invitation/accept_invitation_page.dart';
import 'package:webapp/pages/payment/payment_page.dart';
import 'package:webapp/repositories/ticket_repository.dart';
import 'package:webapp/services/firebase.dart';
import 'package:webapp/services/validator.dart' as val;
import 'package:webapp/utilities/alertGenerator.dart';
import 'package:websafe_svg/websafe_svg.dart';

import 'bloc/authentication_bloc.dart';

class AuthenticationPage extends StatefulWidget {
  final LinkType linkType;
  AuthenticationPage(this.linkType);
  @override
  _AuthenticationPageState createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> with TickerProviderStateMixin {
  AuthenticationBloc signUpBloc;

  final form = FormGroup({
    'fname': FormControl(validators: [Validators.required]),
    'lname': FormControl(validators: [Validators.required]),
    'dobDay': FormControl<int>(validators: [Validators.required, Validators.max(31)]),
    'dobMonth': FormControl<int>(validators: [Validators.required, Validators.max(12)]),
    'dobYear': FormControl<int>(validators: [Validators.required, Validators.max(2009), Validators.min(1900)]),
    'gender': FormControl<Gender>(validators: [Validators.required], value: Gender.Female),
  });

  final double elementSpacing = 16.0;
  final double cardPadding = 20;
  final int animationTime = 400;

  // Not using a reactive form for the login since we're using custom logic for the email field.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmEmailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confirmPwController = TextEditingController();
  bool _validatePW = false;

  int releaseManagerSelected = 0;

  clearData() {
    _emailController.clear();
    _confirmEmailController.clear();
    _pwController.clear();
    _confirmPwController.clear();
    _validatePW = false;
    form.reset();
  }

  @override
  void initState() {
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
    return Scaffold(
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
              constraints: BoxConstraints(maxWidth: MyTheme.maxWidth + 8 + 44),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(cardPadding),
                  child: Column(
                    children: [
                      _buildWhyAreYouHere(),
                      Card(
                        color: Colors.grey[900].withAlpha(150),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            side: BorderSide(color: Color(0xFF707070).withAlpha(90), width: 1)),
                        child: Padding(
                          padding: const EdgeInsets.all(22.0),
                          child: Column(
                            children: [
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
                                              AutoSizeText(
                                                widget.linkType.event.name,
                                                style: MyTheme.mainTT.headline5,
                                              ),
                                              state is StateLoggedIn
                                                  ? SizedBox(
                                                      width: constraints.screenSize.width,
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            SizedBox(
                                                              width: MyTheme.maxWidth - 16 - 106 - 52 - 12 - 40,
                                                              child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    AutoSizeText(
                                                                      "${state.firstName} ${state.lastName}",
                                                                      style: MyTheme.mainTT.bodyText1,
                                                                    ),
                                                                    AutoSizeText(
                                                                      state.email,
                                                                      style: MyTheme.mainTT.bodyText2,
                                                                    ),
                                                                  ]),
                                                            ),
                                                            SizedBox(
                                                              width: 12,
                                                            ),
                                                            SizedBox(
                                                              width: 106,
                                                              height: 34,
                                                              child: RaisedButton(
                                                                onPressed: () {
                                                                  clearData();
                                                                  signUpBloc.add(EventLogout());
                                                                },
                                                                child: Text(
                                                                  "Logout",
                                                                  style: MyTheme.mainTT.button,
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ).paddingTop(elementSpacing)
                                                  : SizedBox.shrink(),
                                              SizedBox(
                                                height: elementSpacing,
                                              ),
                                              Card(
                                                child: _buildEventInfoVertical(screenSize, constraints),
                                              ).appolloCard,
                                              SizedBox(
                                                height: elementSpacing,
                                              ),
                                            ],
                                          );
                                        }
                                      } else {
                                        return Column(
                                          children: [
                                            AutoSizeText(
                                              widget.linkType.event.name,
                                              style: MyTheme.mainTT.headline5,
                                            ),
                                            SizedBox(
                                              height: elementSpacing,
                                            ),
                                            _buildEventInfoHorizontal(screenSize, constraints)
                                          ],
                                        );
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
                                    }
                                  },
                                  buildWhen: (c, state) {
                                    if (state is StateErrorSignUp) {
                                      return false;
                                    }
                                    return true;
                                  },
                                  builder: (c, state) {
                                    if (state is StatePasswordsConfirmed ||
                                        (state is StateLoggedIn &&
                                            (getDeviceType(screenSize) == DeviceScreenType.mobile ||
                                                getDeviceType(screenSize) == DeviceScreenType.watch))) {
                                      return SizedBox.shrink();
                                    } else {
                                      return Column(
                                        children: [
                                          AnimatedSize(
                                            vsync: this,
                                            duration: Duration(milliseconds: animationTime),
                                            child: Container(
                                              constraints: BoxConstraints(maxWidth: MyTheme.maxWidth + 8),
                                              child: Card(
                                                child: Padding(
                                                  padding: EdgeInsets.all(cardPadding),
                                                  child: Column(
                                                    children: [
                                                      _buildEmailAndPWFields(state, screenSize),
                                                      _buildSSO(state, screenSize),
                                                    ],
                                                  ),
                                                ),
                                              ).appolloCard,
                                            ),
                                          ),
                                        ],
                                      )
                                          .paddingTop(getValueForScreenType(
                                              context: context,
                                              desktop: elementSpacing,
                                              tablet: elementSpacing,
                                              mobile: 0,
                                              watch: 0))
                                          .paddingBottom(getValueForScreenType(
                                              context: context,
                                              desktop: state is StateLoggedIn ? elementSpacing : 0,
                                              tablet: state is StateLoggedIn ? elementSpacing : 0,
                                              mobile: 0,
                                              watch: 0));
                                    }
                                  }),
                              BlocConsumer<AuthenticationBloc, AuthenticationState>(
                                  cubit: signUpBloc,
                                  listener: (c, state) {},
                                  buildWhen: (c, state) {
                                    if (state is StateErrorSignUp || state is StateLoadingLogin) {
                                      return false;
                                    }
                                    return true;
                                  },
                                  builder: (c, state) {
                                    print(state);
                                    if (state is StatePasswordsConfirmed) {
                                      return _buildNewUser(screenSize);
                                    } else {
                                      return Container(
                                        height: 0,
                                        width: 0,
                                      );
                                    }
                                  }),
                              BlocBuilder<AuthenticationBloc, AuthenticationState>(
                                cubit: signUpBloc,
                                builder: (c, state) {
                                  if (state is StateLoggedIn) {
                                    return Column(
                                      children: [
                                        _buildFreeTicketCard(),
                                        _buildPaymentCard(),
                                      ],
                                    );
                                  } else {
                                    return Container();
                                  }
                                },
                              ),
                              // Builds the CTA
                              BlocConsumer<AuthenticationBloc, AuthenticationState>(
                                  cubit: signUpBloc,
                                  listener: (c, state) {},
                                  buildWhen: (c, state) {
                                    if (state is StateErrorSignUp) {
                                      return false;
                                    }
                                    return true;
                                  },
                                  builder: (c, state) {
                                    if (state is StateLoggedIn || state is StateLoadingSSO) {
                                      return Container();
                                    } else {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(right: 4.0),
                                            child: Align(
                                                alignment: Alignment.centerRight,
                                                child: _buildMainButtons(state, screenSize)),
                                          ).paddingTop(elementSpacing),
                                        ],
                                      );
                                    }
                                  }),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      _buildPoweredByAppollo(),
                      SizedBox(
                        height: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Input fields required for sign up
  Widget _buildNewUser(Size screenSize) {
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
                      context: context, watch: 0, mobile: 0, desktop: elementSpacing, tablet: elementSpacing),
                ),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(cardPadding),
                    child: ReactiveForm(
                        formGroup: form,
                        child: Column(
                          children: [
                            AutoSizeText(
                              "Finally provide some info about yourself",
                              style: MyTheme.mainTT.headline6,
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            AutoSizeText(
                              "We require this information to issue your ticket. Please note that providing incorrect information might invalidate your ticket. We'll save this data for you, so you'll only have to provide it once.",
                              style: MyTheme.mainTT.bodyText2,
                            ),
                            SizedBox(
                              height: elementSpacing * 2,
                            ),
                            AutoSizeText(
                              "Name",
                              style: MyTheme.mainTT.headline6,
                            ),
                            SizedBox(
                              height: elementSpacing,
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
                                  width: MyTheme.maxWidth - cardPadding * 4,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: (MyTheme.maxWidth - cardPadding * 4 - 26) / 2,
                                        child: ReactiveTextField(
                                          formControlName: 'fname',
                                          validationMessages: (control) => {
                                            ValidationMessage.required: 'Please provide a name',
                                          },
                                          decoration: InputDecoration(labelText: "First Name"),
                                        ),
                                      ),
                                      SizedBox(
                                        width: (MyTheme.maxWidth - cardPadding * 4 - 26) / 2,
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
                              height: elementSpacing * 2,
                            ),
                            ResponsiveBuilder(builder: (context, constraints) {
                              if (constraints.deviceScreenType == DeviceScreenType.mobile ||
                                  constraints.deviceScreenType == DeviceScreenType.watch) {
                                return AutoSizeText(
                                  "Date of birth",
                                  style: MyTheme.mainTT.headline6,
                                );
                              } else {
                                return SizedBox(
                                  width: MyTheme.maxWidth,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      AutoSizeText(
                                        "Date of birth",
                                        style: MyTheme.mainTT.headline6,
                                      ),
                                      SizedBox.shrink(),
                                      AutoSizeText(
                                        "Gender",
                                        style: MyTheme.mainTT.headline6,
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }),
                            SizedBox(
                              height: elementSpacing,
                            ),
                            ResponsiveBuilder(builder: (context, constraints) {
                              if (constraints.deviceScreenType == DeviceScreenType.mobile ||
                                  constraints.deviceScreenType == DeviceScreenType.watch) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: (MyTheme.maxWidth - cardPadding * 6) + 8,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: (MyTheme.maxWidth - cardPadding * 6 - 30) / 3,
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
                                            width: (MyTheme.maxWidth - cardPadding * 6 - 30) / 3,
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
                                            width: (MyTheme.maxWidth - cardPadding * 6 - 30) / 3,
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
                                      height: elementSpacing * 2,
                                    ),
                                    AutoSizeText(
                                      "Gender",
                                      style: MyTheme.mainTT.headline6,
                                    ),
                                    SizedBox(
                                      height: elementSpacing,
                                    ),
                                    SizedBox(
                                      width: (MyTheme.maxWidth - cardPadding * 4) + 8,
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
                                      width: (MyTheme.maxWidth / 2 - cardPadding * 3) + 8,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: (MyTheme.maxWidth / 2 - cardPadding * 3 - 26) / 3,
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
                                            width: (MyTheme.maxWidth / 2 - cardPadding * 3 - 26) / 3,
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
                                            width: (MyTheme.maxWidth / 2 - cardPadding * 3 - 26) / 3,
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
                                      width: (MyTheme.maxWidth / 2 - cardPadding * 3) + 8,
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

  /// Creates the buttons at the bottom allowing user to proceed or return to previous states
  Widget _buildMainButtons(AuthenticationState state, Size screenSize) {
    if (state is StateLoadingLogin) {
      return RaisedButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
          child: SizedBox(
            height: 18,
            width: 34,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Theme(
                  data: Theme.of(context).copyWith(accentColor: Colors.white), child: CircularProgressIndicator()),
            ),
          ),
        ),
        onPressed: () {},
      );
    }
    // Email exists
    else if (state is StateExistingUserEmail) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlineButton(
            borderSide: BorderSide(color: MyTheme.appolloPurple, width: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
              child: Text("Back", style: MyTheme.mainTT.button.copyWith(color: MyTheme.appolloPurple)),
            ),
            onPressed: () {
              signUpBloc.add(EventChangeEmail());
            },
          ),
          RaisedButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
              child: Text("Login", style: MyTheme.mainTT.button),
            ),
            onPressed: () {
              signUpBloc.add(EventLoginPressed(_emailController.text, _pwController.text));
            },
          ),
        ],
      );
    } else if (state is StateNewUserEmailsConfirmed) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlineButton(
            borderSide: BorderSide(color: MyTheme.appolloPurple, width: 5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
              child: Text("Back", style: MyTheme.mainTT.button.copyWith(color: MyTheme.appolloPurple)),
            ),
            onPressed: () {
              signUpBloc.add(EventChangeEmail());
            },
          ),
          RaisedButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
              child: Text("Next", style: MyTheme.mainTT.button),
            ),
            onPressed: () {
              if (_pwController.text.length >= 8 && _pwController.text == _confirmPwController.text) {
                signUpBloc.add(EventPasswordsConfirmed());
              } else {
                setState(() {
                  _validatePW = true;
                });
              }
            },
          ),
        ],
      );
      // User is logged in
    } else if (state is StateNewUserEmail || state is StateNewSSOUser) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlineButton(
            borderSide: BorderSide(color: MyTheme.appolloPurple, width: 5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
              child: Text("Back", style: MyTheme.mainTT.button.copyWith(color: MyTheme.appolloPurple)),
            ),
            onPressed: () {
              signUpBloc.add(EventChangeEmail());
            },
          ),
          RaisedButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
              child: Text("Next", style: MyTheme.mainTT.button),
            ),
            onPressed: () {
              if (_emailController.text == _confirmEmailController.text) {
                if (state is StateNewSSOUser) {
                  print(state.uid);
                  signUpBloc.add(EventSSOEmailsConfirmed(state.uid));
                } else {
                  signUpBloc.add(EventEmailsConfirmed());
                }
              }
            },
          ),
        ],
      );
    } else if (state is StateInitial) {
      return RaisedButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
          child: Text("Next", style: MyTheme.mainTT.button),
        ),
        onPressed: () {
          signUpBloc.add(EventEmailProvided(_emailController.text));
        },
      );
    } else if (state is StatePasswordsConfirmed) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlineButton(
            borderSide: BorderSide(color: MyTheme.appolloPurple, width: 5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
              child: Text("Back", style: MyTheme.mainTT.button.copyWith(color: MyTheme.appolloPurple)),
            ),
            onPressed: () {
              signUpBloc.add(EventChangeEmail());
            },
          ),
          RaisedButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
              child: Text(
                "Register",
                style: MyTheme.mainTT.button,
              ),
            ),
            onPressed: () {
              if (form.valid) {
                try {
                  DateTime dob = DateTime(
                      form.controls["dobYear"].value, form.controls["dobMonth"].value, form.controls["dobDay"].value);
                  signUpBloc.add(EventCreateNewUser(
                      _emailController.text,
                      _pwController.text,
                      form.controls["fname"].value,
                      form.controls["lname"].value,
                      dob,
                      form.controls["gender"].value,
                      state.uid));
                } catch (_) {}
              } else {
                form.markAllAsTouched();
                setState(() {
                  _validatePW = true;
                });
              }
            },
          ),
        ],
      );
    } else {
      return Container(
        height: 0,
      );
    }
  }

  /// Returns info about the users next action
  Widget _buildHeadline(AuthenticationState state, Size screenSize) {
    String text = "";
    if (state is StateLoginFailed) {
      text = "Password doesn't match, please try again";
    } else if (state is StateExistingUserEmail) {
      text = "Welcome back! Please enter your password to login";
    } else if (state is StateNewUserEmail || state is StateNewSSOUser) {
      text = "Please confirm your email address";
    } else if (state is StateNewUserEmailsConfirmed) {
      text = "Create and confirm a password you can easily remember";
    } else {
      return SizedBox(
        width: MyTheme.maxWidth,
        child: Column(
          children: [
            AutoSizeText(
              "Let's start with your email address",
              style: MyTheme.mainTT.subtitle1
                  .copyWith(color: MyTheme.appolloGreen),
            ).paddingBottom(8),
            AutoSizeText(
              "Let's start with your email address",
              style: MyTheme.mainTT.subtitle1
                  .copyWith(color: state is StateLoginFailed ? MyTheme.appolloRed : MyTheme.appolloWhite),
              minFontSize: 12,
            ),
          ],
        ),
      );    }
    return SizedBox(
      width: MyTheme.maxWidth,
      child: AutoSizeText(
        text,
        style: MyTheme.mainTT.subtitle1
            .copyWith(color: state is StateLoginFailed ? MyTheme.appolloRed : MyTheme.appolloWhite),
        minFontSize: 12,
      ),
    );
  }

  /// Returns a single TextInputField initially.
  /// Returns 2 TextInputFields when an unused email was provided for email confirmation
  _buildEmailField(AuthenticationState state, Size screenSize) {
    if (state is StateInitial)
      return Container(
        key: ValueKey(1),
        constraints: BoxConstraints(maxWidth: MyTheme.maxWidth),
        child: Focus(
          child: TextFormField(
            autofillHints: [AutofillHints.email],
            controller: _emailController,
            onFieldSubmitted: (v) {
              signUpBloc.add(EventEmailProvided(_emailController.text));
            },
            decoration: InputDecoration(
                labelText: "Email Address",
                labelStyle: MyTheme.mainTT.bodyText2,
                suffixIcon: state is StateLoadingUserData
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      )
                    : SizedBox.shrink()),
            autovalidateMode: state is StateInvalidEmail ? AutovalidateMode.always : AutovalidateMode.disabled,
            validator: (v) => val.Validator.validateEmail(_emailController.text),
          ),
        ),
      );
    // Prompt confirm email
    else if (state is StateNewUserEmail || state is StateNewSSOUser) {
      return Column(
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MyTheme.maxWidth),
            child: Focus(
              child: TextFormField(
                autofillHints: [AutofillHints.email],
                controller: _emailController,
                onFieldSubmitted: (v) {
                  if (_emailController.text == _confirmEmailController.text) {
                    if (state is StateNewSSOUser) {
                      signUpBloc.add(EventSSOEmailsConfirmed(state.uid));
                    } else {
                      signUpBloc.add(EventEmailsConfirmed());
                    }
                  }
                },
                decoration: InputDecoration(
                    labelText: "Email Address",
                    labelStyle: MyTheme.mainTT.bodyText2,
                    suffixIcon: state is StateLoadingUserData
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          )
                        : Container(
                            height: 0,
                            width: 0,
                          )),
                autovalidateMode: state is StateInvalidEmail ? AutovalidateMode.always : AutovalidateMode.disabled,
                validator: (v) => val.Validator.validateEmail(_emailController.text),
              ),
            ),
          ),
          SizedBox(
            height: 12,
          ),
          Container(
            constraints: BoxConstraints(maxWidth: MyTheme.maxWidth),
            child: Focus(
              child: TextFormField(
                autofillHints: [AutofillHints.email],
                autofocus: true,
                controller: _confirmEmailController,
                onFieldSubmitted: (v) {
                  if (_emailController.text == _confirmEmailController.text) {
                    if (state is StateNewSSOUser) {
                      signUpBloc.add(EventSSOEmailsConfirmed(state.uid));
                    } else {
                      signUpBloc.add(EventEmailsConfirmed());
                    }
                  }
                },
                decoration: InputDecoration(
                    labelText: "Confirm Email Address",
                    labelStyle: MyTheme.mainTT.bodyText2,
                    suffixIcon: state is StateLoadingUserData
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          )
                        : Container(
                            height: 0,
                            width: 0,
                          )),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (v) =>
                    _confirmEmailController.text == _emailController.text ? null : "Please make sure your emails match",
              ),
            ),
          )
        ],
      );
    } else {
      return SizedBox.shrink();
    }
  }

  _buildPoweredByAppollo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: elementSpacing,
        ),
        Text(
          "Powered by",
          style: MyTheme.mainTT.caption.copyWith(
              color: Colors.grey[200],
              fontWeight: FontWeight.w300,
              shadows: [BoxShadow(color: Colors.black, blurRadius: 1, spreadRadius: 1)]),
        ),
        Text("appollo",
            style: MyTheme.mainTT.subtitle1.copyWith(
                fontFamily: "cocon",
                color: Colors.white,
                fontSize: 20,
                shadows: [BoxShadow(color: Colors.black, blurRadius: 1, spreadRadius: 1)])),
        SizedBox(
          height: elementSpacing,
        ),
      ],
    );
  }

  // Desktop
  _buildEventInfoHorizontal(Size screenSize, SizingInformation constraints) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: MyTheme.maxWidth / 2 - elementSpacing / 2),
          width: constraints.localWidgetSize.width / 2 - elementSpacing / 2,
          height: MyTheme.maxWidth / 4,
          child: Card(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              child: ExtendedImage.network(widget.linkType.event.coverImageURL, cache: true, fit: BoxFit.cover,
                  loadStateChanged: (ExtendedImageState state) {
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
              }),
            ),
          ),
        ),
        SizedBox(
          width: elementSpacing,
        ),
        Container(
          constraints: BoxConstraints(maxWidth: MyTheme.maxWidth / 2 - elementSpacing / 2),
          width: constraints.localWidgetSize.width / 2 - elementSpacing / 2,
          height: MyTheme.maxWidth / 4,
          child: Card(
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12.0), child: _buildEventInfoText()),
          ).appolloCard,
        ),
      ],
    );
  }

  // Mobile
  _buildEventInfoVertical(Size screenSize, SizingInformation constraints) {
    return Column(
      children: [
        Container(
          width: constraints.localWidgetSize.width - 8,
          child: AspectRatio(
            aspectRatio: 2,
            child: ExtendedImage.network(widget.linkType.event.coverImageURL, cache: true, fit: BoxFit.cover,
                loadStateChanged: (ExtendedImageState state) {
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
            }),
          ),
        ).paddingBottom(8),
        Container(
          width: constraints.localWidgetSize.width - 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildEventInfoText(),
          ),
        ),
      ],
    );
  }

  Widget _buildEventInfoText() {
    List<Widget> widgets = List<Widget>();
    widgets.add(
      AutoSizeText("Event details", style: MyTheme.mainTT.headline6).paddingBottom(8),
    );
    widgets.add(
      AutoSizeText("Date: " + DateFormat.yMd().format(widget.linkType.event.date), maxLines: 1).paddingBottom(8),
    );
    widgets.add(
      AutoSizeText("Start: " + DateFormat.jm().format(widget.linkType.event.date), maxLines: 1).paddingBottom(8),
    );
    if (widget.linkType.event.address != null) {
      widgets.add(
        AutoSizeText("Location: " + widget.linkType.event.address, maxLines: 1).paddingBottom(8),
      );
    } else {
      widgets.add(
        AutoSizeText("Location: " + widget.linkType.event.venueName, maxLines: 1).paddingBottom(8),
      );
    }
    /* widgets.add(AutoSizeText(
      "This invitation is valid until ${StringFormatter.getDateTime(widget.linkType.event.date.subtract(Duration(hours: widget.linkType.event.cutoffTimeOffset)), showSeconds: false)}",
      maxLines: 2,
    ));*/
    if (widget.linkType.event.invitationMessage != "") {
      widgets.add(AutoSizeText(
        "Conditions:",
        style: MyTheme.mainTT.subtitle2,
      ));
      widgets.add(AutoSizeText(
        widget.linkType.event.invitationMessage,
        maxLines: 3,
      ).paddingBottom(8));
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildSSO(AuthenticationState state, Size screenSize) {
    if ((js.window.navigator.userAgent.contains("iPhone") && !js.window.navigator.userAgent.contains("Safari")) ||
        js.window.navigator.userAgent.contains("wv")) {
      return Container();
    }
    if (state is StateLoadingSSO) {
      return SizedBox(
        height: 180,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CircularProgressIndicator(),
            AutoSizeText("Please log in using the popup"),
            AutoSizeText("Can't see any popup? Please make sure your browser isn't blocking it."),
          ],
        ),
      ).paddingTop(elementSpacing);
    } else if (state is StateLoadingCreateUser) {
      return SizedBox(
        height: 180,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CircularProgressIndicator(),
            AutoSizeText("Setting up your account ..."),
          ],
        ),
      ).paddingTop(elementSpacing);
    } else if (state is StateInitial) {
      return Column(
        children: [
          SizedBox(
            height: 12,
          ),
          AutoSizeText(
            "Or continue with",
            style: MyTheme.mainTT.subtitle1,
          ),
          SizedBox(
            height: 12,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  signUpBloc.add(EventGoogleSignIn());
                },
                child: WebsafeSvg.asset("assets/icons/google_icon.svg", height: 70, width: 70),
              ),
              SizedBox(
                width: 12,
              ),
              InkWell(
                onTap: () {
                  signUpBloc.add(EventFacebookSignIn());
                },
                child: WebsafeSvg.asset("assets/icons/facebook_icon.svg", height: 70, width: 70),
              ),
              SizedBox(
                width: 12,
              ),
              InkWell(
                onTap: () {
                  signUpBloc.add(EventAppleSignIn());
                },
                child: Container(
                    child: WebsafeSvg.asset("assets/icons/apple_icon.svg",
                        color: MyTheme.appolloWhite, height: 70, width: 70)),
              ),
            ],
          ),
        ],
      ).paddingTop(elementSpacing);
    } else {
      return SizedBox.shrink();
    }
  }

  /// Builds TextInputFields for the initial email fields as well as email and password confirmation
  _buildEmailAndPWFields(AuthenticationState state, Size screenSize) {
    if (state is StateLoadingSSO || state is StateLoadingCreateUser) {
      return Container();
    } else if (state is StateNewUserEmail || state is StateNewSSOUser) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildHeadline(state, screenSize),
          SizedBox(
            height: elementSpacing,
          ),
          AnimatedSwitcher(
            duration: Duration(milliseconds: animationTime),
            child: _buildEmailField(state, screenSize),
          ),
        ],
      );
    } else if (state is StateLoggedIn) {
      return Container(
        constraints: BoxConstraints(maxWidth: MyTheme.maxWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: MyTheme.maxWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MyTheme.maxWidth / 2,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      AutoSizeText(
                        "You are logged in as",
                        style: MyTheme.mainTT.subtitle2,
                      ),
                      AutoSizeText(
                        "${state.firstName} ${state.lastName}",
                        style: MyTheme.mainTT.bodyText2,
                      ),
                    ]),
                  ),
                  SizedBox(
                    width: 106,
                    height: 34,
                    child: RaisedButton(
                      onPressed: () {
                        clearData();
                        signUpBloc.add(EventLogout());
                      },
                      child: Text(
                        "Logout",
                        style: MyTheme.mainTT.button,
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: elementSpacing,
            ),
            AutoSizeText(
              "Email",
              style: MyTheme.mainTT.subtitle2,
            ),
            AutoSizeText(
              state.email,
              style: MyTheme.mainTT.bodyText2,
            ),
          ],
        ),
      );
    } else if (state is StateInitial) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildHeadline(state, screenSize),
          SizedBox(
            height: elementSpacing,
          ),
          AnimatedSwitcher(
            duration: Duration(milliseconds: animationTime),
            child: _buildEmailField(state, screenSize),
          ),
        ],
      );
    } else if (state is StateNewUserEmailsConfirmed) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildHeadline(state, screenSize),
          SizedBox(
            height: elementSpacing,
          ),
          Container(
            constraints: BoxConstraints(maxWidth: MyTheme.maxWidth),
            child: TextFormField(
              autofillHints: [AutofillHints.password],
              controller: _pwController,
              autofocus: true,
              obscureText: true,
              validator: (v) => val.Validator.validatePassword(v),
              autovalidateMode: _validatePW ? AutovalidateMode.always : AutovalidateMode.disabled,
              onFieldSubmitted: (v) {
                if (_pwController.text.length >= 8 && _confirmPwController.text == _pwController.text) {
                  signUpBloc.add(EventPasswordsConfirmed());
                } else {
                  setState(() {
                    _validatePW = true;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: "Password",
                labelStyle: MyTheme.mainTT.bodyText2,
              ),
            ),
          ),
          SizedBox(
            height: elementSpacing,
          ),
          Container(
            constraints: BoxConstraints(maxWidth: MyTheme.maxWidth),
            child: TextFormField(
              autofillHints: [AutofillHints.password],
              controller: _confirmPwController,
              obscureText: true,
              validator: (v) =>
                  _confirmPwController.text == _pwController.text ? null : "Please make sure your passwords match",
              autovalidateMode: _validatePW ? AutovalidateMode.always : AutovalidateMode.disabled,
              onFieldSubmitted: (v) {
                if (_pwController.text.length >= 8 && _confirmPwController.text == _pwController.text) {
                  signUpBloc.add(EventPasswordsConfirmed());
                } else {
                  setState(() {
                    _validatePW = true;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: "Confirm Password",
                labelStyle: MyTheme.mainTT.bodyText2,
              ),
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildHeadline(state, screenSize),
          SizedBox(
            height: elementSpacing,
          ),
          AnimatedSwitcher(
            duration: Duration(milliseconds: animationTime),
            child: _buildEmailField(state, screenSize),
          ),
          SizedBox(
            height: elementSpacing,
          ),
          Container(
            constraints: BoxConstraints(maxWidth: MyTheme.maxWidth),
            child: TextFormField(
              autofillHints: [AutofillHints.password],
              controller: _pwController,
              obscureText: true,
              autofocus: true,
              validator: (v) => val.Validator.validatePassword(v),
              autovalidateMode: _validatePW ? AutovalidateMode.always : AutovalidateMode.disabled,
              onFieldSubmitted: (v) {
                if (state is StateExistingUserEmail) {
                  signUpBloc.add(EventLoginPressed(_emailController.text, _pwController.text));
                }
              },
              decoration: InputDecoration(
                labelText: "Password",
                labelStyle: MyTheme.mainTT.bodyText2,
              ),
            ),
          ),
          state is StateExistingUserEmail
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: elementSpacing,
                      ),
                      InkWell(
                          onTap: () {
                            if (_emailController.text != "") {
                              AlertGenerator.showAlertWithChoice(
                                      context: context,
                                      title: "Reset your password",
                                      content:
                                          "Need to reset your password? We'll send out an email to ${_emailController.text} with further instructions",
                                      buttonText1: "Reset",
                                      buttonText2: "Cancel")
                                  .then((value) {
                                if (value != null && value) {
                                  FBServices.instance.resetPassword(_emailController.text);
                                }
                              });
                            }
                          },
                          child: Text("FORGOT PASSWORD?")),
                    ],
                  ),
                )
              : Container()
        ],
      );
    }
  }

  Widget _buildWhyAreYouHere() {
    if (widget.linkType is AdvertisementInvite) {
      return AutoSizeText("");
    }

    String text = "";

    if (widget.linkType is PromoterInvite) {
      PromoterInvite invitation = widget.linkType;
      text =
          "${invitation.promoter.firstName} ${invitation.promoter.lastName} has invited you to an event.\nFollow the instructions below to accept your invite!";
    } else if (widget.linkType is BirthdayList) {
      BirthdayList invitation = widget.linkType;
      text =
          "${invitation.promoter.firstName} ${invitation.promoter.lastName} has invited you to their birthday party.\nFollow the instructions below to accept your invite!";
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
      color: MyTheme.appolloGreen,
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          children: [
            AutoSizeText(
              text,
              style: MyTheme.mainTT.bodyText1,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFreeTicketCard() {
    if (widget.linkType.event.getReleasesWithSingleTicketRestriction().length != 0) {
      return FreeTicketPage(widget.linkType).paddingTop(20);
    } else {
      return Container();
    }
  }

  Widget _buildPaymentCard() {
    if (widget.linkType.event.getReleasesWithoutRestriction().length != 0) {
      return PaymentPage(widget.linkType.event).paddingTop(20);
    } else {
      return Container();
    }
  }
}
