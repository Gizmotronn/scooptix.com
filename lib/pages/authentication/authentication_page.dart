import 'dart:async';
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
import 'package:webapp/model/link_type/birthdayList.dart';
import 'package:webapp/model/link_type/link_type.dart';
import 'package:webapp/model/link_type/promoterInvite.dart';
import 'package:webapp/model/release_manager.dart';
import 'package:webapp/model/ticket_release.dart';
import 'package:webapp/pages/accept_invitation/accept_invitation_page.dart';
import 'package:webapp/repositories/ticket_repository.dart';
import 'package:webapp/services/firebase.dart';
import 'package:webapp/services/string_formatter.dart';
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
    'gender': FormControl<int>(validators: [Validators.required, Validators.max(3), Validators.min(0)], value: 3),
  });

  final double elementSpacing = 16.0;
  final double cardPadding = 20;
  final int animationTime = 400;

  // Not using a reactive form for the login since we're using custom logic for the email field.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  bool _validatePW = false;
  DateTime lastEmailChange = DateTime.now();
  Timer autoCheckEmailTimer;
  String lastEmailChecked = "";

  int releaseManagerSelected = 0;

  @override
  void initState() {
    autoCheckEmailTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (signUpBloc.state is StateInitial &&
          _emailController.text != "" &&
          lastEmailChecked != _emailController.text &&
          DateTime.now().difference(lastEmailChange).inSeconds > 4) {
        lastEmailChecked = _emailController.text;
        signUpBloc.add(EventEmailProvided(_emailController.text));
      }
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
                filter: ImageFilter.blur(sigmaX: 80.0, sigmaY: 80.0),
                child: Container(
                  width: screenSize.width,
                  height: screenSize.height,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.0)),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              constraints: BoxConstraints(maxWidth: MyTheme.maxWidth + 8 + 44),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ResponsiveBuilder(builder: (context, constraints) {
                      if (constraints.deviceScreenType == DeviceScreenType.mobile ||
                          constraints.deviceScreenType == DeviceScreenType.watch) {
                        return Container();
                      } else {
                        return SizedBox(
                          height: 20,
                        );
                      }
                    }),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                      color: Color(0xFFf8f8f8),
                      child: Padding(
                        padding: const EdgeInsets.all(22.0),
                        child: Column(
                          children: [
                            AutoSizeText(
                              widget.linkType.event.name,
                              style: MyTheme.mainTT.headline5,
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            _buildWhyAreYouHere(),
                            SizedBox(
                              height: 20,
                            ),
                            ResponsiveBuilder(builder: (context, constraints) {
                              if (constraints.deviceScreenType == DeviceScreenType.mobile ||
                                  constraints.deviceScreenType == DeviceScreenType.watch) {
                                return _buildEventInfoVertical(screenSize, constraints);
                              } else {
                                return _buildEventInfoHorizontal(screenSize, constraints);
                              }
                            }),
                            SizedBox(
                              height: elementSpacing,
                            ),
                            // Builds the login functionality
                            BlocConsumer<AuthenticationBloc, AuthenticationState>(
                                cubit: signUpBloc,
                                listener: (c, state) {
                                  if (state is StateErrorSignUp) {
                                    String text =
                                        "We couldn't create an account for you, please make sure your password is at least 8 characters long";
                                    if (state.error == SignUpError.UserCancelled) {
                                      text = "Login Cancelled";
                                    } else {
                                      text = "An error occurred during the signup process, please try again";
                                    }
                                    AlertGenerator.showAlert(
                                        context: context,
                                        title: "Error",
                                        content: text,
                                        buttonText: "Ok",
                                        popTwice: false);
                                  }
                                },
                                buildWhen: (c, state) {
                                  if (state is StateErrorSignUp) {
                                    return false;
                                  }
                                  return true;
                                },
                                builder: (c, state) {
                                  print(state);
                                  return Column(
                                    children: [
                                      Column(
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
                                                      _buildEmailPWLogin(state, screenSize),
                                                      SizedBox(
                                                        height: elementSpacing,
                                                      ),
                                                      _buildSSO(state, screenSize),
                                                    ],
                                                  ),
                                                ),
                                              ).appolloCard,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
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
                                  if (state is StateNewUserEmail || state is StateNewSSOUser) {
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
                                  return AcceptInvitationPage(widget.linkType).paddingTop(20);
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
                                  if (state is StateInitial || state is StateLoggedIn || state is StateLoadingSSO) {
                                    return Container();
                                  } else {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        SizedBox(
                                          height: elementSpacing,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(right: 4.0),
                                          child: Align(
                                              alignment: Alignment.centerRight,
                                              child: _buildLoginAndSignUpButton(state, screenSize)),
                                        ),
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
                      height: 100,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewUser(Size screenSize) {
    return SizedBox(
      width: screenSize.width,
      child: Column(
        children: [
          SizedBox(
            height: elementSpacing,
          ),
          Container(
            constraints: BoxConstraints(maxWidth: MyTheme.maxWidth + 8),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(cardPadding),
                    child: ReactiveForm(
                        formGroup: form,
                        child: Column(
                          children: [
                            AutoSizeText(
                              "Some information about yourself",
                              style: MyTheme.mainTT.headline6,
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            AutoSizeText(
                              "We require this information to issue your ticket. Please note that providing incorrect information might invalidate your ticket. We'll save this data for you, so you'll only have to provide it once.",
                              style: MyTheme.mainTT.bodyText1,
                            ),
                            SizedBox(
                              height: elementSpacing,
                            ),
                            ReactiveTextField(
                              formControlName: 'fname',
                              validationMessages: (control) => {
                                ValidationMessage.required: 'Please provide a name',
                              },
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  enabledBorder: OutlineInputBorder(),
                                  labelText: "First Name"),
                            ),
                            SizedBox(
                              height: elementSpacing,
                            ),
                            ReactiveTextField(
                              formControlName: 'lname',
                              validationMessages: (control) => {
                                ValidationMessage.required: 'Please provide a name',
                              },
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  enabledBorder: OutlineInputBorder(),
                                  labelText: "Last Name"),
                            ),
                            SizedBox(
                              height: elementSpacing * 2,
                            ),
                            AutoSizeText(
                              "Date of birth",
                              style: MyTheme.mainTT.headline6,
                            ),
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
                                      width: (MyTheme.maxWidth - cardPadding),
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
                                          border: OutlineInputBorder(),
                                          hintText: "DD",
                                          labelText: 'Day',
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: (MyTheme.maxWidth - cardPadding),
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
                                          border: OutlineInputBorder(),
                                          hintText: "MM",
                                          labelText: 'Month',
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: (MyTheme.maxWidth - cardPadding),
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
                                          border: OutlineInputBorder(),
                                          hintText: "YYYY",
                                          labelText: 'Year',
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: (MyTheme.maxWidth - cardPadding * 2 - 30) / 3,
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
                                          border: OutlineInputBorder(),
                                          hintText: "DD",
                                          labelText: 'Day',
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: (MyTheme.maxWidth - cardPadding * 2 - 30) / 3,
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
                                          border: OutlineInputBorder(),
                                          hintText: "MM",
                                          labelText: 'Month',
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: (MyTheme.maxWidth - cardPadding * 2 - 30) / 3,
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
                                          border: OutlineInputBorder(),
                                          hintText: "YYYY",
                                          labelText: 'Year',
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }
                            }),
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
                            ResponsiveBuilder(builder: (context, constraints) {
                              if (constraints.deviceScreenType == DeviceScreenType.mobile ||
                                  constraints.deviceScreenType == DeviceScreenType.watch) {
                                return Column(
                                  children: [
                                    SizedBox(
                                      width: (MyTheme.maxWidth - cardPadding * 2),
                                      child: ReactiveRadioListTile(
                                        title: Text('Female'),
                                        value: 0,
                                        formControlName: 'gender',
                                      ),
                                    ),
                                    SizedBox(
                                      width: (MyTheme.maxWidth - cardPadding),
                                      child: ReactiveRadioListTile(
                                        title: Text('Male'),
                                        value: 1,
                                        formControlName: 'gender',
                                      ),
                                    ),
                                    SizedBox(
                                      width: (MyTheme.maxWidth - cardPadding * 2),
                                      child: ReactiveRadioListTile(
                                        title: Text('Other'),
                                        value: 2,
                                        formControlName: 'gender',
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                return Row(
                                  children: [
                                    SizedBox(
                                      width: (MyTheme.maxWidth - cardPadding * 2 - 30) / 3,
                                      child: ReactiveRadioListTile(
                                        title: Text('Female'),
                                        value: 0,
                                        formControlName: 'gender',
                                      ),
                                    ),
                                    SizedBox(
                                      width: (MyTheme.maxWidth - cardPadding * 2 - 30) / 3,
                                      child: ReactiveRadioListTile(
                                        title: Text('Male'),
                                        value: 1,
                                        formControlName: 'gender',
                                      ),
                                    ),
                                    SizedBox(
                                      width: (MyTheme.maxWidth - cardPadding * 2 - 30) / 3,
                                      child: ReactiveRadioListTile(
                                        title: Text('Other'),
                                        value: 2,
                                        formControlName: 'gender',
                                      ),
                                    ),
                                  ],
                                );
                              }
                            }),
                          ],
                        )),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketSales(StateLoggedIn state, Size screenSize) {
    return Container(
      constraints: BoxConstraints(maxWidth: MyTheme.maxWidth + 8),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(cardPadding),
          child: Column(
            children: [
              SizedBox(
                height: elementSpacing,
              ),
              AutoSizeText(
                "Please select which tickets you would like to buy.",
                style: MyTheme.mainTT.headline6,
              ),
              SizedBox(
                height: elementSpacing,
              ),
              _buildTicketReleases(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginAndSignUpButton(AuthenticationState state, Size screenSize) {
    if (state is StateLoadingSSO || state is StateLoggedIn || state is StateLoadingCreateUser) {
      return Container(
        height: 0,
      );
    } else if (state is StateLoadingLogin) {
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
      return RaisedButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
          child: Text("Login", style: MyTheme.mainTT.button),
        ),
        onPressed: () {
          signUpBloc.add(EventLoginPressed(_emailController.text, _pwController.text));
        },
      );
      // User is logged in
    } else {
      return RaisedButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
          child: Text(
            "Continue to your ticket",
            style: MyTheme.mainTT.button,
          ),
        ),
        onPressed: () {
          if (form.valid && (state is StateNewSSOUser || _pwController.text.length >= 8)) {
            try {
              if (state is StateNewSSOUser) {
                _emailController.text = state.email;
              }
              DateTime dob = DateTime(
                  form.controls["dobYear"].value, form.controls["dobMonth"].value, form.controls["dobDay"].value);
              signUpBloc.add(EventCreateNewUser(_emailController.text, _pwController.text, form.controls["fname"].value,
                  form.controls["lname"].value, dob, form.controls["gender"].value));
            } catch (_) {}
          } else {
            form.markAllAsTouched();
            setState(() {
              _validatePW = true;
            });
          }
        },
      );
    }
  }

  _buildHeadline(AuthenticationState state, Size screenSize) {
    String text = "";
    if (state is StateLoginFailed) {
      text = "Password doesn't match, please try again";
    } else if (state is StateExistingUserEmail) {
      text = "Welcome back! Please enter your password to login.";
    } else {
      text = "Sign Up or Log In to accept your invitation";
    }
    return SizedBox(
      width: MyTheme.maxWidth,
      child: AutoSizeText(
        text,
        style: MyTheme.mainTT.subtitle2
            .copyWith(color: state is StateLoginFailed ? MyTheme.appolloRed : MyTheme.appolloBlack),
        minFontSize: 12,
      ),
    );
  }

  /// Returns a label containing the user's email if the user has already provided their email, otherwise returns a TextInputField
  _buildEmailField(AuthenticationState state, Size screenSize) {
    if (state is StateInitial)
      return Container(
        key: ValueKey(1),
        constraints: BoxConstraints(maxWidth: MyTheme.maxWidth),
        child: Focus(
          onFocusChange: (hasFocus) {
            if (!hasFocus) {
              signUpBloc.add(EventEmailProvided(_emailController.text));
            }
          },
          child: TextFormField(
            autofillHints: [AutofillHints.email],
            controller: _emailController,
            onChanged: (v) {
              lastEmailChange = DateTime.now();
            },
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(),
                border: OutlineInputBorder(),
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
      );
    else {
      return Container(
        key: ValueKey(2),
        constraints: BoxConstraints(maxWidth: MyTheme.maxWidth),
        child: InkWell(
          onTap: () {
            if (state is StateExistingUserEmail || state is StateNewUserEmail) {
              lastEmailChange = DateTime.now();
              signUpBloc.add(EventChangeEmail());
            }
          },
          child: Align(
              alignment: Alignment.centerLeft,
              child: ListTile(
                subtitle: AutoSizeText(
                  _emailController.text,
                  style: MyTheme.mainTT.subtitle1,
                ),
                title: AutoSizeText(
                  "Email (tap to change)",
                  style: MyTheme.mainTT.bodyText1,
                ),
                contentPadding: EdgeInsets.all(0),
              )),
        ),
      );
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
          style: MyTheme.mainTT.headline6.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              shadows: [BoxShadow(color: Colors.black, blurRadius: 1, spreadRadius: 1)]),
        ),
        Text("appollo",
            style: MyTheme.mainTT.headline5.copyWith(
                fontFamily: "cocon",
                color: Colors.white,
                fontWeight: FontWeight.w700,
                shadows: [BoxShadow(color: Colors.black, blurRadius: 1, spreadRadius: 1)])),
        SizedBox(
          height: elementSpacing,
        ),
      ],
    );
  }

  _buildEventInfoHorizontal(Size screenSize, SizingInformation constraints) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: MyTheme.maxWidth / 2 - elementSpacing / 2),
          width: constraints.localWidgetSize.width / 2 - elementSpacing / 2,
          height: MyTheme.maxWidth / 4,
          child: Card(
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(10)),
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
          ).appolloCard,
        ),
        SizedBox(
          width: elementSpacing,
        ),
        Container(
          constraints: BoxConstraints(maxWidth: MyTheme.maxWidth / 2 - elementSpacing / 2),
          width: constraints.localWidgetSize.width / 2 - elementSpacing / 2,
          height: MyTheme.maxWidth / 4,
          child: Card(
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0), child: _buildEventInfoText()),
          ).appolloCard,
        ),
      ],
    );
  }

  _buildEventInfoVertical(Size screenSize, SizingInformation constraints) {
    return Column(
      children: [
        Container(
          width: constraints.localWidgetSize.width - 4,
          height: MyTheme.maxWidth / 4,
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(10)),
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
        SizedBox(
          height: elementSpacing,
        ),
        Container(
          decoration: ShapeDecoration(
              color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
          width: constraints.localWidgetSize.width - 4,
          height: MyTheme.maxWidth / 4,
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0), child: _buildEventInfoText()),
        ),
      ],
    );
  }

  Widget _buildEventInfoText() {
    List<Widget> widgets = List<Widget>();
    widgets.add(
      AutoSizeText("Date: " + DateFormat.yMd().format(widget.linkType.event.date), maxLines: 1),
    );
    widgets.add(
      AutoSizeText("Start: " + DateFormat.jm().format(widget.linkType.event.date), maxLines: 1),
    );
    widgets.add(
      AutoSizeText(
        "This invitation is valid until until ${StringFormatter.getDateTime(widget.linkType.event.date.subtract(Duration(hours: widget.linkType.event.cutoffTimeOffset)), showSeconds: false)}",
        maxLines: 2,
      ),
    );
    if (widget.linkType.event.invitationMessage != "") {
      widgets.add(AutoSizeText(
        widget.linkType.event.invitationMessage,
        maxLines: 3,
      ));
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  _buildSSO(AuthenticationState state, Size screenSize) {
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
      );
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
      );
    } else if (state is StateInitial) {
      return Column(
        children: [
          SizedBox(
            height: 12,
          ),
          AutoSizeText(
            "Or continue with",
            style: MyTheme.mainTT.subtitle2,
          ),
          SizedBox(
            height: 12,
          ),
          ResponsiveBuilder(builder: (context, constraints) {
            if (constraints.deviceScreenType == DeviceScreenType.mobile ||
                constraints.deviceScreenType == DeviceScreenType.watch) {
              return Column(
                children: [
                  Container(
                    height: 40,
                    width: 230,
                    margin: EdgeInsets.all(8),
                    child: RaisedButton(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(6.0),
                      ),
                      textColor: Colors.black,
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                            width: 12,
                          ),
                          WebsafeSvg.asset(
                            "assets/icons/google.svg",
                            height: 18,
                            width: 18,
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: Container(
                              alignment: FractionalOffset(0.35, 0.5),
                              child: AutoSizeText(
                                "Google",
                                style: MyTheme.mainTT.button.copyWith(color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                      onPressed: () {
                        signUpBloc.add(EventGoogleSignIn());
                      },
                    ),
                  ),
                  Container(
                    height: 40,
                    width: 230,
                    margin: EdgeInsets.all(8),
                    child: RaisedButton(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(6.0),
                      ),
                      textColor: Colors.black,
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                            width: 12,
                          ),
                          Image.asset(
                            "assets/icons/facebook.png",
                            height: 18,
                            width: 18,
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: Container(
                              alignment: FractionalOffset(0.35, 0.5),
                              child: AutoSizeText(
                                "Facebook",
                                style: MyTheme.mainTT.button.copyWith(color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                      onPressed: () {
                        signUpBloc.add(EventFacebookSignIn());
                      },
                    ),
                  ),
                  Container(
                    height: 40,
                    width: 230,
                    margin: EdgeInsets.all(8),
                    child: RaisedButton(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(6.0),
                      ),
                      textColor: Colors.black,
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                            width: 12,
                          ),
                          WebsafeSvg.asset(
                            "assets/icons/apple.svg",
                            height: 18,
                            width: 18,
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: Container(
                              alignment: FractionalOffset(0.35, 0.5),
                              child: AutoSizeText(
                                "Apple",
                                style: MyTheme.mainTT.button.copyWith(color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                      onPressed: () {
                        signUpBloc.add(EventAppleSignIn());
                      },
                    ),
                  ),
                ],
              );
            } else {
              return Row(
                children: [
                  Container(
                    height: 40,
                    width: 170,
                    margin: EdgeInsets.all(8),
                    child: RaisedButton(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(6.0),
                      ),
                      textColor: Colors.black,
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                            width: 12,
                          ),
                          WebsafeSvg.asset(
                            "assets/icons/google.svg",
                            height: 18,
                            width: 18,
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: Container(
                              alignment: FractionalOffset(0.35, 0.5),
                              child: AutoSizeText(
                                "Google",
                                style: MyTheme.mainTT.button.copyWith(color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                      onPressed: () {
                        signUpBloc.add(EventGoogleSignIn());
                      },
                    ),
                  ),
                  Container(
                    height: 40,
                    width: 170,
                    margin: EdgeInsets.all(8),
                    child: RaisedButton(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(6.0),
                      ),
                      textColor: Colors.black,
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                            width: 12,
                          ),
                          Image.asset(
                            "assets/icons/facebook.png",
                            height: 18,
                            width: 18,
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: Container(
                              alignment: FractionalOffset(0.35, 0.5),
                              child: AutoSizeText(
                                "Facebook",
                                style: MyTheme.mainTT.button.copyWith(color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                      onPressed: () {
                        signUpBloc.add(EventFacebookSignIn());
                      },
                    ),
                  ),
                  Container(
                    height: 40,
                    width: 170,
                    margin: EdgeInsets.all(8),
                    child: RaisedButton(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(6.0),
                      ),
                      textColor: Colors.black,
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                            width: 12,
                          ),
                          WebsafeSvg.asset(
                            "assets/icons/apple.svg",
                            height: 18,
                            width: 18,
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: Container(
                              alignment: FractionalOffset(0.35, 0.5),
                              child: AutoSizeText(
                                "Apple",
                                style: MyTheme.mainTT.button.copyWith(color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                      onPressed: () {
                        signUpBloc.add(EventAppleSignIn());
                      },
                    ),
                  ),
                ],
              );
            }
          }),
        ],
      );
    } else {
      return Container(
        height: 0,
      );
    }
  }

  _buildEmailPWLogin(AuthenticationState state, Size screenSize) {
    if (state is StateLoadingSSO || state is StateLoadingCreateUser) {
      return Container();
    } else if (state is StateNewSSOUser) {
      return Container(
        constraints: BoxConstraints(maxWidth: MyTheme.maxWidth),
        child: InkWell(
          onTap: () {
            signUpBloc.add(EventChangeEmail());
          },
          child: Align(
              alignment: Alignment.centerLeft,
              child: ListTile(
                subtitle: AutoSizeText(
                  state.email,
                  style: MyTheme.mainTT.subtitle1,
                ),
                title: AutoSizeText(
                  "Email",
                  style: MyTheme.mainTT.bodyText1,
                ),
                contentPadding: EdgeInsets.all(0),
              )),
        ),
      );
    } else if (state is StateLoggedIn) {
      return Container(
        constraints: BoxConstraints(maxWidth: MyTheme.maxWidth),
        child: Column(
          children: [
            SizedBox(
              width: MyTheme.maxWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MyTheme.maxWidth / 2,
                    child: ListTile(
                      subtitle: AutoSizeText(
                        "${state.firstName} ${state.lastName}",
                        style: MyTheme.mainTT.subtitle1,
                      ),
                      title: AutoSizeText(
                        "You are logged in as",
                        style: MyTheme.mainTT.bodyText1,
                      ),
                      contentPadding: EdgeInsets.all(0),
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    height: 40,
                    child: RaisedButton(
                      onPressed: () {
                        _emailController.text = "";
                        _pwController.text = "";
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
            ListTile(
              subtitle: AutoSizeText(
                state.email,
                style: MyTheme.mainTT.subtitle1,
              ),
              title: AutoSizeText(
                "Email",
                style: MyTheme.mainTT.bodyText1,
              ),
              contentPadding: EdgeInsets.all(0),
            ),
          ],
        ),
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
              validator: (v) => val.Validator.validatePassword(v),
              autovalidateMode: _validatePW ? AutovalidateMode.always : AutovalidateMode.disabled,
              onFieldSubmitted: (v) {
                if (state is StateExistingUserEmail) {
                  signUpBloc.add(EventLoginPressed(_emailController.text, _pwController.text));
                } else {
                  if (form.valid && (state is StateNewSSOUser || _pwController.text.length >= 8)) {
                    try {
                      if (state is StateNewSSOUser) {
                        _emailController.text = state.email;
                      }
                      DateTime dob = DateTime(form.controls["dobYear"].value, form.controls["dobMonth"].value,
                          form.controls["dobDay"].value);
                      signUpBloc.add(EventCreateNewUser(
                          _emailController.text,
                          _pwController.text,
                          form.controls["fname"].value,
                          form.controls["lname"].value,
                          dob,
                          form.controls["gender"].value));
                    } catch (_) {}
                  } else {
                    form.markAllAsTouched();
                    setState(() {
                      _validatePW = true;
                    });
                  }
                }
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(),
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

  Widget _buildTicketReleases() {
    List<Widget> widgets = [];
    if (widget.linkType.event.releaseManagers.length > 0) {
      widgets.add(
        DropdownButtonFormField(
          decoration: InputDecoration.collapsed(hintText: ""),
          value: releaseManagerSelected,
          items: widget.linkType.event.releaseManagers.map((ReleaseManager value) {
            return new DropdownMenuItem<int>(
              value: value.index,
              child: Builder(
                builder: (context) {
                  return Text(value.name);
                },
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              releaseManagerSelected = value;
            });
          },
        ),
      );

      TicketRelease tr = widget.linkType.event.releaseManagers[releaseManagerSelected].getActiveRelease();
      if (tr != null) {
        tr.ticketTypes.forEach((ticketType) {
          widgets.add(
            Column(
              children: [
                AutoSizeText("${tr.description}"),
                Row(
                  children: [
                    SizedBox(
                      height: 40,
                      width: 150,
                      child: TextField(
                        decoration: new InputDecoration(labelText: "Number of tickets"),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ], // Only numbers can be entered
                      ),
                    ),
                    AutoSizeText(" x ${ticketType.name}"),
                    Expanded(
                        child: Align(
                            alignment: Alignment.centerRight,
                            child: AutoSizeText("\$${(ticketType.price / 100).toStringAsFixed(2)}")))
                  ],
                ),
              ],
            ),
          );
        });
      } else {
        widgets.add(AutoSizeText("Sold Out"));
      }

      return Column(
        children: widgets,
      );
    } else {
      widget.linkType.event.releases.forEach((release) {
        widgets.add(Text(release.name));
      });

      return Column(
        children: widgets,
      );
    }
  }

  Widget _buildWhyAreYouHere() {
    if (widget.linkType is PromoterInvite) {
      PromoterInvite invitation = widget.linkType;
      return Column(
        children: [
          AutoSizeText(
            "${invitation.promoter.firstName} ${invitation.promoter.lastName} has invited you to join their guest list.",
            style: MyTheme.mainTT.subtitle2, textAlign: TextAlign.center,
          ),
          AutoSizeText("Follow the instructions below to claim your ticket!", textAlign: TextAlign.center, style: MyTheme.mainTT.subtitle2)
        ],
      );
    } else if (widget.linkType is BirthdayList) {
      BirthdayList invitation = widget.linkType;
      return Column(
        children: [
          AutoSizeText(
              "${invitation.promoter.firstName} ${invitation.promoter.lastName} has invited you to join their birthday party.",
              style: MyTheme.mainTT.subtitle2, textAlign: TextAlign.center),
          AutoSizeText("Follow the instructions below to claim your ticket!", textAlign: TextAlign.center, style: MyTheme.mainTT.subtitle2)
        ],
      );
    } else {
      return AutoSizeText("");
    }
  }
}
