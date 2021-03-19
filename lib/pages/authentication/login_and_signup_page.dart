import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:ticketapp/UI/authentication/signUpForm.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/model/user.dart';
import 'package:ticketapp/services/firebase.dart';
import 'package:ticketapp/utilities/alertGenerator.dart';
import 'dart:html' as js;
import 'package:ticketapp/services/validator.dart' as val;
import 'package:websafe_svg/websafe_svg.dart';
import 'bloc/authentication_bloc.dart';

class LoginAndSignupPage extends StatefulWidget {
  static const String routeName = '/loginSignUp';

  final AuthenticationBloc bloc;
  final TextTheme textTheme;

  const LoginAndSignupPage({Key key, @required this.bloc, @required this.textTheme}) : super(key: key);

  @override
  _LoginAndSignupPageState createState() => _LoginAndSignupPageState();
}

class _LoginAndSignupPageState extends State<LoginAndSignupPage> {
  FormGroup form;
  final int animationTime = 400;

  // Not using a reactive form for the login since we're using custom logic for the email field.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmEmailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confirmPwController = TextEditingController();
  bool _validatePW = false;
  bool _termsAccepted = false;

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
    return BlocConsumer<AuthenticationBloc, AuthenticationState>(
        cubit: widget.bloc,
        listener: (c, state) {
          if (state is StateNewSSOUser) {
            _emailController.text = state.email;
            form.controls["fname"].value = state.firstName;
            form.controls["lname"].value = state.lastName;
          }
        },
        builder: (c, state) {
          if (state is StatePasswordsConfirmed) {
            return Column(
              children: [
                SignUpForm(form: form, textTheme: widget.textTheme),
                SizedBox(
                  height: MyTheme.elementSpacing,
                ),
                _buildMainButtons(state, screenSize),
              ],
            );
          } else {
            return Column(
              children: [
                _buildEmailAndPWFields(state, screenSize),
                SizedBox(
                  height: MyTheme.elementSpacing,
                ),
                _buildMainButtons(state, screenSize),
                _buildSSO(state, screenSize),
              ],
            );
          }
        });
  }

  /// Creates the buttons at the bottom allowing user to proceed or return to previous states
  Widget _buildMainButtons(AuthenticationState state, Size screenSize) {
    print(state);
    if (state is StateLoadingLogin) {
      return ResponsiveBuilder(builder: (context, constraints) {
        if (constraints.deviceScreenType == DeviceScreenType.mobile ||
            constraints.deviceScreenType == DeviceScreenType.watch) {
          return SizedBox(
            width: screenSize.width,
            child: RaisedButton(
              color: MyTheme.appolloGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
                child: SizedBox(
                  height: 18,
                  width: 34,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Theme(
                        data: Theme.of(context).copyWith(accentColor: Colors.white),
                        child: CircularProgressIndicator()),
                  ),
                ),
              ),
              onPressed: () {},
            ),
          );
        } else {
          return Align(
            alignment: Alignment.centerRight,
            child: RaisedButton(
              color: MyTheme.appolloGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
                child: SizedBox(
                  height: 18,
                  width: 34,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Theme(
                        data: Theme.of(context).copyWith(accentColor: Colors.white),
                        child: CircularProgressIndicator()),
                  ),
                ),
              ),
              onPressed: () {},
            ),
          );
        }
      });
    }
    // Email exists
    else if (state is StateExistingUserEmail) {
      return ResponsiveBuilder(builder: (context, constraints) {
        if (constraints.deviceScreenType == DeviceScreenType.mobile ||
            constraints.deviceScreenType == DeviceScreenType.watch) {
          return Column(
            children: [
              SizedBox(
                width: screenSize.width,
                child: RaisedButton(
                  color: MyTheme.appolloGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
                    child: Text("Login", style: widget.textTheme.button),
                  ),
                  onPressed: () {
                    widget.bloc.add(EventLoginPressed(_emailController.text, _pwController.text));
                  },
                ),
              ).paddingBottom(8),
              SizedBox(
                width: screenSize.width,
                child: OutlineButton(
                  color: MyTheme.appolloGreen,
                  borderSide: BorderSide(color: MyTheme.appolloGreen, width: 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
                    child: Text("Back", style: widget.textTheme.button.copyWith(color: MyTheme.appolloGreen)),
                  ),
                  onPressed: () {
                    widget.bloc.add(EventChangeEmail());
                  },
                ),
              ),
            ],
          );
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlineButton(
                color: MyTheme.appolloGreen,
                borderSide: BorderSide(color: MyTheme.appolloGreen, width: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
                  child: Text("Back", style: widget.textTheme.button.copyWith(color: MyTheme.appolloGreen)),
                ),
                onPressed: () {
                  widget.bloc.add(EventChangeEmail());
                },
              ),
              RaisedButton(
                color: MyTheme.appolloGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
                  child: Text("Login", style: widget.textTheme.button),
                ),
                onPressed: () {
                  widget.bloc.add(EventLoginPressed(_emailController.text, _pwController.text));
                },
              ),
            ],
          );
        }
      });
    } else if (state is StateNewUserEmailsConfirmed) {
      return ResponsiveBuilder(builder: (context, constraints) {
        if (constraints.deviceScreenType == DeviceScreenType.mobile ||
            constraints.deviceScreenType == DeviceScreenType.watch) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: screenSize.width,
                child: RaisedButton(
                  color: MyTheme.appolloGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
                    child: Text("Next", style: widget.textTheme.button),
                  ),
                  onPressed: () {
                    if (_pwController.text.length >= 8 && _pwController.text == _confirmPwController.text) {
                      widget.bloc.add(EventPasswordsConfirmed());
                    } else {
                      setState(() {
                        _validatePW = true;
                      });
                    }
                  },
                ),
              ).paddingBottom(8),
              SizedBox(
                width: screenSize.width,
                child: OutlineButton(
                  color: MyTheme.appolloGreen,
                  borderSide: BorderSide(color: MyTheme.appolloGreen, width: 5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
                    child: Text("Back", style: widget.textTheme.button.copyWith(color: MyTheme.appolloGreen)),
                  ),
                  onPressed: () {
                    widget.bloc.add(EventChangeEmail());
                  },
                ),
              ),
            ],
          );
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlineButton(
                color: MyTheme.appolloGreen,
                borderSide: BorderSide(color: MyTheme.appolloGreen, width: 5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
                  child: Text("Back", style: widget.textTheme.button.copyWith(color: MyTheme.appolloGreen)),
                ),
                onPressed: () {
                  widget.bloc.add(EventChangeEmail());
                },
              ),
              RaisedButton(
                color: MyTheme.appolloGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
                  child: Text("Next", style: widget.textTheme.button),
                ),
                onPressed: () {
                  if (_pwController.text.length >= 8 && _pwController.text == _confirmPwController.text) {
                    widget.bloc.add(EventPasswordsConfirmed());
                  } else {
                    setState(() {
                      _validatePW = true;
                    });
                  }
                },
              ),
            ],
          );
        }
      });

      // User is logged in
    } else if (state is StateNewUserEmail || state is StateNewSSOUser) {
      return ResponsiveBuilder(builder: (context, constraints) {
        if (constraints.deviceScreenType == DeviceScreenType.mobile ||
            constraints.deviceScreenType == DeviceScreenType.watch) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: screenSize.width,
                child: RaisedButton(
                  color: MyTheme.appolloGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
                    child: Text("Next", style: widget.textTheme.button),
                  ),
                  onPressed: () {
                    if (_emailController.text == _confirmEmailController.text) {
                      if (state is StateNewSSOUser) {
                        widget.bloc.add(EventSSOEmailsConfirmed(state.uid));
                      } else {
                        widget.bloc.add(EventEmailsConfirmed());
                      }
                    }
                  },
                ),
              ).paddingBottom(8),
              SizedBox(
                width: screenSize.width,
                child: OutlineButton(
                  color: MyTheme.appolloGreen,
                  borderSide: BorderSide(color: MyTheme.appolloGreen, width: 5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
                    child: Text("Back", style: widget.textTheme.button.copyWith(color: MyTheme.appolloGreen)),
                  ),
                  onPressed: () {
                    widget.bloc.add(EventChangeEmail());
                  },
                ),
              ),
            ],
          );
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlineButton(
                color: MyTheme.appolloGreen,
                borderSide: BorderSide(color: MyTheme.appolloGreen, width: 5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
                  child: Text("Back", style: widget.textTheme.button.copyWith(color: MyTheme.appolloGreen)),
                ),
                onPressed: () {
                  widget.bloc.add(EventChangeEmail());
                },
              ),
              RaisedButton(
                color: MyTheme.appolloGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
                  child: Text("Next", style: widget.textTheme.button),
                ),
                onPressed: () {
                  if (_emailController.text == _confirmEmailController.text) {
                    if (state is StateNewSSOUser) {
                      widget.bloc.add(EventSSOEmailsConfirmed(state.uid));
                    } else {
                      widget.bloc.add(EventEmailsConfirmed());
                    }
                  }
                },
              ),
            ],
          );
        }
      });
    } else if (state is StateInitial) {
      return ResponsiveBuilder(builder: (context, constraints) {
        if (constraints.deviceScreenType == DeviceScreenType.mobile ||
            constraints.deviceScreenType == DeviceScreenType.watch) {
          return SizedBox(
            width: screenSize.width,
            child: RaisedButton(
              color: MyTheme.appolloGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
                child: Text("Next", style: widget.textTheme.button),
              ),
              onPressed: () {
                widget.bloc.add(EventEmailProvided(_emailController.text));
              },
            ),
          ).paddingBottom(8);
        } else {
          return Align(
            alignment: Alignment.centerRight,
            child: RaisedButton(
              color: MyTheme.appolloGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
                child: Text("Next", style: widget.textTheme.button),
              ),
              onPressed: () {
                widget.bloc.add(EventEmailProvided(_emailController.text));
              },
            ),
          );
        }
      });
    } else if (state is StatePasswordsConfirmed) {
      return ResponsiveBuilder(builder: (context, constraints) {
        if (constraints.deviceScreenType == DeviceScreenType.mobile ||
            constraints.deviceScreenType == DeviceScreenType.watch) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: screenSize.width,
                child: RaisedButton(
                  color: MyTheme.appolloGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
                    child: Text(
                      "Register",
                      style: widget.textTheme.button,
                    ),
                  ),
                  onPressed: () {
                    if (form.valid) {
                      try {
                        DateTime dob = DateTime(form.controls["dobYear"].value, form.controls["dobMonth"].value,
                            form.controls["dobDay"].value);
                        widget.bloc.add(EventCreateNewUser(
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
                      if (!_termsAccepted) {
                        AlertGenerator.showAlert(
                            context: context,
                            title: "Missing info",
                            content: "Please accept our terms & conditions to sign up",
                            buttonText: "Ok",
                            popTwice: false);
                      }
                    }
                  },
                ),
              ).paddingBottom(8),
              SizedBox(
                width: screenSize.width,
                child: OutlineButton(
                  color: MyTheme.appolloGreen,
                  borderSide: BorderSide(color: MyTheme.appolloGreen, width: 5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
                    child: Text("Back", style: widget.textTheme.button.copyWith(color: MyTheme.appolloGreen)),
                  ),
                  onPressed: () {
                    widget.bloc.add(EventChangeEmail());
                  },
                ),
              ),
            ],
          );
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlineButton(
                color: MyTheme.appolloGreen,
                borderSide: BorderSide(color: MyTheme.appolloGreen, width: 5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
                  child: Text("Back", style: widget.textTheme.button.copyWith(color: MyTheme.appolloGreen)),
                ),
                onPressed: () {
                  widget.bloc.add(EventChangeEmail());
                },
              ),
              RaisedButton(
                color: MyTheme.appolloGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
                  child: Text(
                    "Register",
                    style: widget.textTheme.button,
                  ),
                ),
                onPressed: () {
                  if (form.valid) {
                    try {
                      DateTime dob = DateTime(form.controls["dobYear"].value, form.controls["dobMonth"].value,
                          form.controls["dobDay"].value);
                      widget.bloc.add(EventCreateNewUser(
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
                    if (!_termsAccepted) {
                      AlertGenerator.showAlert(
                          context: context,
                          title: "Missing info",
                          content: "Please accept our terms & conditions to sign up",
                          buttonText: "Ok",
                          popTwice: false);
                    }
                  }
                },
              ),
            ],
          );
        }
      });
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
          crossAxisAlignment: getValueForScreenType(
              context: context,
              watch: CrossAxisAlignment.center,
              mobile: CrossAxisAlignment.center,
              tablet: CrossAxisAlignment.start,
              desktop: CrossAxisAlignment.start),
          children: [
            ResponsiveBuilder(builder: (context, constraints) {
              if (constraints.deviceScreenType == DeviceScreenType.mobile ||
                  constraints.deviceScreenType == DeviceScreenType.watch) {
                return AutoSizeText(
                  "Get your ticket in just a few steps",
                  maxLines: 1,
                  style: widget.textTheme.headline6.copyWith(color: MyTheme.appolloGreen),
                ).paddingBottom(MyTheme.elementSpacing);
              } else {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AutoSizeText(
                      "Get your ticket in just a few steps",
                      style: widget.textTheme.headline6.copyWith(color: MyTheme.appolloGreen),
                    ),
                    InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          widget.bloc.add(OnTapCloseSignEvent());
                        },
                        child: Icon(
                          Icons.close,
                          size: 34,
                          color: Colors.grey,
                        )),
                  ],
                ).paddingBottom(MyTheme.elementSpacing);
              }
            }),
            AutoSizeText(
              "Let's start with your email address",
              style: widget.textTheme.subtitle2
                  .copyWith(color: state is StateLoginFailed ? MyTheme.appolloRed : widget.textTheme.subtitle2.color),
              minFontSize: 12,
            ),
          ],
        ),
      );
    }
    return SizedBox(
      width: MyTheme.maxWidth,
      child: Align(
        alignment: getValueForScreenType(
            context: context,
            watch: Alignment.center,
            mobile: Alignment.center,
            tablet: Alignment.centerLeft,
            desktop: Alignment.centerLeft),
        child: AutoSizeText(
          text,
          textAlign: getValueForScreenType(
              context: context,
              watch: TextAlign.center,
              mobile: TextAlign.center,
              tablet: TextAlign.left,
              desktop: TextAlign.left),
          style: widget.textTheme.headline6
              .copyWith(color: state is StateLoginFailed ? MyTheme.appolloRed : widget.textTheme.subtitle2.color),
          minFontSize: 12,
        ),
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
              widget.bloc.add(EventEmailProvided(_emailController.text));
            },
            decoration: InputDecoration(
                labelText: "Email Address",
                labelStyle: widget.textTheme.bodyText2,
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
                      widget.bloc.add(EventSSOEmailsConfirmed(state.uid));
                    } else {
                      widget.bloc.add(EventEmailsConfirmed());
                    }
                  }
                },
                decoration: InputDecoration(
                    labelText: "Email Address",
                    labelStyle: widget.textTheme.bodyText2,
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
                      widget.bloc.add(EventSSOEmailsConfirmed(state.uid));
                    } else {
                      widget.bloc.add(EventEmailsConfirmed());
                    }
                  }
                },
                decoration: InputDecoration(
                    labelText: "Confirm Email Address",
                    labelStyle: widget.textTheme.bodyText2,
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
            AutoSizeText(
              "Please log in using the popup",
              style: widget.textTheme.bodyText2,
            ),
            AutoSizeText("Can't see any popup? Please make sure your browser isn't blocking it.",
                style: widget.textTheme.bodyText2),
          ],
        ),
      ).paddingTop(MyTheme.elementSpacing);
    } else if (state is StateLoadingCreateUser) {
      return SizedBox(
        height: 180,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CircularProgressIndicator(),
            AutoSizeText(
              "Setting up your account ...",
              style: widget.textTheme.bodyText2,
            ),
          ],
        ),
      ).paddingTop(MyTheme.elementSpacing);
    } else if (state is StateInitial) {
      return Column(
        children: [
          SizedBox(
            height: 12,
          ),
          AutoSizeText(
            "Or continue with",
            style: widget.textTheme.subtitle1,
          ),
          SizedBox(
            height: 12,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  widget.bloc.add(EventGoogleSignIn());
                },
                child: WebsafeSvg.asset("icons/google_icon.svg", height: 70, width: 70),
              ),
              SizedBox(
                width: 12,
              ),
              InkWell(
                onTap: () {
                  widget.bloc.add(EventFacebookSignIn());
                },
                child: WebsafeSvg.asset("icons/facebook_icon.svg", height: 70, width: 70),
              ),
              SizedBox(
                width: 12,
              ),
              InkWell(
                onTap: () {
                  widget.bloc.add(EventAppleSignIn());
                },
                child: Container(
                    child: WebsafeSvg.asset("icons/apple_icon.svg",
                        color: widget.textTheme.bodyText2.color, height: 70, width: 70)),
              ),
            ],
          ),
        ],
      ).paddingTop(MyTheme.elementSpacing);
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
            height: MyTheme.elementSpacing,
          ),
          AnimatedSwitcher(
            duration: Duration(milliseconds: animationTime),
            child: _buildEmailField(state, screenSize),
          ),
        ],
      );
    } else if (state is StateLoggedIn) {
      return Container();
    } else if (state is StateInitial) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildHeadline(state, screenSize),
          SizedBox(
            height: MyTheme.elementSpacing,
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
            height: MyTheme.elementSpacing,
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
                  widget.bloc.add(EventPasswordsConfirmed());
                } else {
                  setState(() {
                    _validatePW = true;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: "Password",
                labelStyle: widget.textTheme.bodyText2,
              ),
            ),
          ),
          SizedBox(
            height: MyTheme.elementSpacing,
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
                  widget.bloc.add(EventPasswordsConfirmed());
                } else {
                  setState(() {
                    _validatePW = true;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: "Confirm Password",
                labelStyle: widget.textTheme.bodyText2,
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
            height: MyTheme.elementSpacing,
          ),
          AnimatedSwitcher(
            duration: Duration(milliseconds: animationTime),
            child: _buildEmailField(state, screenSize),
          ),
          SizedBox(
            height: MyTheme.elementSpacing,
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
                  widget.bloc.add(EventLoginPressed(_emailController.text, _pwController.text));
                }
              },
              decoration: InputDecoration(
                labelText: "Password",
                labelStyle: widget.textTheme.bodyText2,
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
                        height: MyTheme.elementSpacing,
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
                          child: Text(
                            "FORGOT PASSWORD?",
                            style: widget.textTheme.bodyText2,
                          )),
                    ],
                  ),
                )
              : Container()
        ],
      );
    }
  }
}
