import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:ticketapp/UI/authentication/signUpForm.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/appollo/appollo_progress_indicator.dart';
import 'package:ticketapp/UI/widgets/buttons/apollo_button.dart';
import 'package:ticketapp/UI/widgets/icons/svgicon.dart';
import 'package:ticketapp/UI/widgets/textfield/appollo_textfield.dart';
import 'package:ticketapp/main.dart';
import 'package:ticketapp/model/user.dart';
import 'package:ticketapp/services/firebase.dart';
import 'package:ticketapp/utilities/alertGenerator.dart';
import 'dart:html' as js;
import 'bloc/authentication_bloc.dart';

class LoginAndSignupPage extends StatefulWidget {
  static const String routeName = '/loginSignUp';

  final AuthenticationBloc bloc;

  const LoginAndSignupPage({Key key, @required this.bloc}) : super(key: key);

  @override
  _LoginAndSignupPageState createState() => _LoginAndSignupPageState();
}

class _LoginAndSignupPageState extends State<LoginAndSignupPage> {
  FormGroup form;
  FormGroup passwordsForm;
  FormGroup initialEmailForm;
  FormGroup confirmEmailForm;
  FormGroup loginForm;

  final int animationTime = 400;

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

    passwordsForm = FormGroup({
      'password': FormControl<String>(validators: [Validators.required, Validators.minLength(8)]),
      'repeat': FormControl<String>(validators: [Validators.required, Validators.minLength(8)]),
    }, validators: [
      Validators.mustMatch("password", "repeat")
    ]);

    initialEmailForm = FormGroup({
      'email': FormControl<String>(validators: [Validators.required, Validators.email]),
    });

    loginForm = FormGroup({
      'password': FormControl<String>(validators: [Validators.required, Validators.minLength(8)]),
    });

    confirmEmailForm = FormGroup({
      'email': FormControl<String>(validators: [Validators.required, Validators.email]),
      'repeat': FormControl<String>(validators: [Validators.required, Validators.email]),
    }, validators: [
      Validators.mustMatch("email", "repeat")
    ]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: BlocConsumer<AuthenticationBloc, AuthenticationState>(
          cubit: widget.bloc,
          listener: (c, state) {
            if (state is StateNewSSOUser) {
              confirmEmailForm.controls["email"].value = state.email;
              form.controls["fname"].value = state.firstName;
              form.controls["lname"].value = state.lastName;
            }
          },
          builder: (c, state) {
            if (state is StatePasswordsConfirmed) {
              return Column(
                children: [
                  SignUpForm(form: form),
                  SizedBox(
                    height: MyTheme.elementSpacing,
                  ),
                  _buildMainButtons(state, screenSize),
                ],
              );
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildEmailAndPWFields(state, screenSize),
                  SizedBox(
                    height: MyTheme.elementSpacing,
                  ),
                  SizedBox(
                    height: getValueForScreenType(
                        context: context,
                        watch: screenSize.height * 0.08,
                        mobile: screenSize.height * 0.08,
                        tablet: 0,
                        desktop: 0),
                  ),
                  _buildMainButtons(state, screenSize),
                  _buildSSO(state, screenSize),
                ],
              );
            }
          }),
    );
  }

  /// Creates the buttons at the bottom allowing user to proceed or return to previous states
  Widget _buildMainButtons(AuthenticationState state, Size screenSize) {
    if (state is StateLoadingLogin || state is StateLoadingUserData) {
      return ResponsiveBuilder(builder: (context, constraints) {
        if (constraints.deviceScreenType == DeviceScreenType.mobile ||
            constraints.deviceScreenType == DeviceScreenType.watch) {
          return SizedBox(
            width: screenSize.width,
            child: AppolloButton.regularButton(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: AppolloButtonProgressIndicator(),
              ),
              onTap: () {},
            ),
          );
        } else {
          return Align(
            alignment: Alignment.centerRight,
            child: AppolloButton.regularButton(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: AppolloButtonProgressIndicator(),
              ),
              onTap: () {},
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
                child: AppolloButton.regularButton(
                  child: Text("Login", style: MyTheme.textTheme.button),
                  onTap: () {
                    widget.bloc.add(EventLoginPressed(initialEmailForm.value["email"], loginForm.value["password"]));
                  },
                ),
              ).paddingBottom(8),
            ],
          );
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppolloButton.regularButton(
                fill: false,
                color: MyTheme.appolloBackgroundColorLight,
                child: Text("Back", style: MyTheme.textTheme.button.copyWith(color: MyTheme.appolloGreen)),
                onTap: () {
                  widget.bloc.add(EventChangeEmail());
                },
              ),
              AppolloButton.regularButton(
                child: Text("Login", style: MyTheme.textTheme.button),
                onTap: () {
                  widget.bloc.add(EventLoginPressed(initialEmailForm.value["email"], loginForm.value["password"]));
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
                height: MyTheme.elementSpacing,
              ),
              SizedBox(
                width: screenSize.width,
                child: AppolloButton.regularButton(
                  child: Text("Next", style: MyTheme.textTheme.button.copyWith(color: MyTheme.appolloBackgroundColor)),
                  onTap: () {
                    passwordsForm.markAllAsTouched();
                    if (!passwordsForm.hasErrors) {
                      widget.bloc.add(EventPasswordsConfirmed());
                    }
                  },
                ),
              ).paddingBottom(8),
              _buildBackButton(screenSize)
            ],
          );
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppolloButton.regularButton(
                fill: false,
                color: MyTheme.appolloBackgroundColorLight,
                child: Text("Back", style: MyTheme.textTheme.button.copyWith(color: MyTheme.appolloGreen)),
                onTap: () {
                  widget.bloc.add(EventChangeEmail());
                },
              ),
              AppolloButton.regularButton(
                fill: true,
                color: MyTheme.appolloGreen,
                child: Text("Next", style: MyTheme.textTheme.button),
                onTap: () {
                  passwordsForm.markAllAsTouched();
                  if (!passwordsForm.hasErrors) {
                    widget.bloc.add(EventPasswordsConfirmed());
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
                child: AppolloButton.regularButton(
                  child: Text("Next", style: MyTheme.textTheme.button),
                  onTap: () {
                    if (!confirmEmailForm.hasErrors) {
                      if (state is StateNewSSOUser) {
                        widget.bloc.add(EventSSOEmailsConfirmed(state.uid));
                      } else {
                        widget.bloc.add(EventEmailsConfirmed());
                      }
                    }
                  },
                ),
              ).paddingBottom(8),
            ],
          );
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppolloButton.regularButton(
                fill: false,
                child: Text("Back", style: MyTheme.textTheme.button.copyWith(color: MyTheme.appolloGreen)),
                onTap: () {
                  widget.bloc.add(EventChangeEmail());
                },
              ),
              AppolloButton.regularButton(
                child: Text("Next", style: MyTheme.textTheme.button),
                onTap: () {
                  if (!confirmEmailForm.hasErrors) {
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
            child: AppolloButton.regularButton(
              child: Text("Next", style: MyTheme.textTheme.button),
              onTap: () {
                initialEmailForm.markAllAsTouched();
                if (!initialEmailForm.hasErrors) {
                  widget.bloc.add(EventEmailProvided(initialEmailForm.value["email"]));
                }
              },
            ),
          ).paddingBottom(8).paddingTop(MyTheme.elementSpacing);
        } else {
          return Align(
            alignment: Alignment.centerRight,
            child: AppolloButton.regularButton(
              color: MyTheme.appolloGreen,
              fill: true,
              child: state is StateLoadingUserData
                  ? SizedBox(
                      height: 18,
                      width: 34,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: AppolloButtonProgressIndicator(),
                      ),
                    )
                  : Text("Next", style: MyTheme.textTheme.button),
              onTap: () {
                initialEmailForm.markAllAsTouched();
                if (!initialEmailForm.hasErrors) {
                  widget.bloc.add(EventEmailProvided(initialEmailForm.value["email"]));
                }
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
                child: AppolloButton.regularButton(
                  child: Text(
                    "Register",
                    style: MyTheme.textTheme.button,
                  ),
                  onTap: () {
                    if (form.valid) {
                      try {
                        DateTime dob = DateTime(form.controls["dobYear"].value, form.controls["dobMonth"].value,
                            form.controls["dobDay"].value);
                        widget.bloc.add(EventCreateNewUser(
                            confirmEmailForm.value["email"],
                            passwordsForm.value["password"],
                            form.controls["fname"].value,
                            form.controls["lname"].value,
                            dob,
                            form.controls["gender"].value,
                            state.uid));
                      } catch (_) {}
                    } else {
                      form.markAllAsTouched();

                      if (!_termsAccepted) {
                        AlertGenerator.showAlert(
                            context: WrapperPage.mainScaffold.currentContext,
                            title: "Missing info",
                            content: "Please accept our terms & conditions to sign up",
                            buttonText: "Ok",
                            popTwice: false);
                      }
                    }
                  },
                ),
              ).paddingBottom(MyTheme.elementSpacing),
              _buildBackButton(screenSize),
            ],
          );
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppolloButton.regularButton(
                fill: false,
                color: MyTheme.appolloBackgroundColorLight,
                child: Text("Back", style: MyTheme.textTheme.button.copyWith(color: MyTheme.appolloGreen)),
                onTap: () {
                  widget.bloc.add(EventChangeEmail());
                },
              ),
              AppolloButton.regularButton(
                fill: true,
                color: MyTheme.appolloGreen,
                child: Text(
                  "Register",
                  style: MyTheme.textTheme.button,
                ),
                onTap: () {
                  if (form.valid) {
                    try {
                      DateTime dob = DateTime(form.controls["dobYear"].value, form.controls["dobMonth"].value,
                          form.controls["dobDay"].value);
                      widget.bloc.add(EventCreateNewUser(
                          confirmEmailForm.value["email"],
                          passwordsForm.value["password"],
                          form.controls["fname"].value,
                          form.controls["lname"].value,
                          dob,
                          form.controls["gender"].value,
                          state.uid));
                    } catch (_) {}
                  } else {
                    form.markAllAsTouched();

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
      text = "Please enter your password.";
    } else if (state is StateNewUserEmail || state is StateNewSSOUser) {
      text = "Please confirm your email address";
    } else if (state is StateNewUserEmailsConfirmed) {
      text = "Please create a password.";
    } else {
      return SizedBox(
        width: MyTheme.maxWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResponsiveBuilder(builder: (context, constraints) {
              if (constraints.deviceScreenType == DeviceScreenType.mobile ||
                  constraints.deviceScreenType == DeviceScreenType.watch) {
                return AutoSizeText(
                  "Let's start with your email.",
                  maxLines: 1,
                  style: MyTheme.textTheme.headline5.copyWith(color: MyTheme.appolloGreen),
                ).paddingBottom(MyTheme.elementSpacing);
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      "Sign up or sign in",
                      style: MyTheme.textTheme.headline2.copyWith(color: MyTheme.appolloWhite),
                    ).paddingBottom(MyTheme.elementSpacing * 2),
                    AutoSizeText(
                      "Let's start with your email.",
                      style: MyTheme.textTheme.headline4.copyWith(color: MyTheme.appolloGreen),
                    ),
                  ],
                ).paddingBottom(MyTheme.elementSpacing * 0.5);
              }
            }),
            AutoSizeText(
              "Welcome, please enter your email to continue.",
              style: MyTheme.textTheme.bodyText2.copyWith(
                color: state is StateLoginFailed ? MyTheme.appolloRed : MyTheme.appolloWhite,
              ),
              minFontSize: 12,
            ),
            SizedBox(
              height: getValueForScreenType(
                  context: context,
                  watch: MyTheme.elementSpacing,
                  mobile: MyTheme.elementSpacing,
                  tablet: 0,
                  desktop: 0),
            ),
          ],
        ),
      );
    }
    return SizedBox(
      width: MyTheme.maxWidth,
      child: Align(
        alignment: Alignment.centerLeft,
        child: AutoSizeText(
          text,
          textAlign: TextAlign.left,
          style: MyTheme.textTheme.headline5
              .copyWith(color: state is StateLoginFailed ? MyTheme.appolloRed : MyTheme.appolloGreen),
          minFontSize: 12,
        ),
      ),
    );
  }

  /// Returns a single TextInputField initially.
  /// Returns 2 TextInputFields when an unused email was provided for email confirmation
  _buildEmailField(AuthenticationState state, Size screenSize) {
    if (state is StateInitial)
      return ReactiveForm(
        formGroup: initialEmailForm,
        child: Container(
          key: ValueKey(1),
          constraints: BoxConstraints(maxWidth: MyTheme.maxWidth),
          child: Focus(
            child: AppolloTextField(
              formControlName: "email",
              textFieldType: TextFieldType.reactive,
              autofillHints: [AutofillHints.email],
              validationMessages: (control) => {
                ValidationMessage.required: 'Please provide an email',
                ValidationMessage.email: 'Please provide a valid email',
              },
              onFieldSubmitted: (v) {
                initialEmailForm.markAllAsTouched();
                if (!initialEmailForm.hasErrors) {
                  setState(() {
                    confirmEmailForm.controls["email"].value = initialEmailForm.value["email"];
                  });
                  widget.bloc.add(EventEmailProvided(initialEmailForm.value["email"]));
                }
              },
              labelText: "Email",
            ),
          ),
        ),
      );
    // Prompt confirm email
    else if (state is StateNewUserEmail || state is StateNewSSOUser) {
      return ReactiveForm(
        formGroup: confirmEmailForm,
        child: Column(
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: MyTheme.maxWidth),
              child: Focus(
                child: AppolloTextField(
                  textFieldType: TextFieldType.reactive,
                  formControlName: "email",
                  labelText: "Email",
                  validationMessages: (control) => {
                    ValidationMessage.required: 'Please provide an email',
                    ValidationMessage.email: 'Please provide a valid email',
                  },
                  autofillHints: [AutofillHints.email],
                  onFieldSubmitted: (v) {
                    if (!confirmEmailForm.hasErrors) {
                      if (state is StateNewSSOUser) {
                        widget.bloc.add(EventSSOEmailsConfirmed(state.uid));
                      } else {
                        widget.bloc.add(EventEmailsConfirmed());
                      }
                    }
                  },
                ),
              ),
            ),
            SizedBox(
              height: 12,
            ),
            Container(
              constraints: BoxConstraints(maxWidth: MyTheme.maxWidth),
              child: Focus(
                child: AppolloTextField(
                  labelText: "Confirm Email",
                  textFieldType: TextFieldType.reactive,
                  validationMessages: (control) => {
                    ValidationMessage.required: 'Please provide an email',
                    ValidationMessage.email: 'Please provide a valid email',
                    ValidationMessage.mustMatch: "Emails must match"
                  },
                  formControlName: "repeat",
                  autofillHints: [AutofillHints.email],
                  autofocus: true,
                  onFieldSubmitted: (v) {
                    if (!confirmEmailForm.hasErrors) {
                      if (state is StateNewSSOUser) {
                        widget.bloc.add(EventSSOEmailsConfirmed(state.uid));
                      } else {
                        widget.bloc.add(EventEmailsConfirmed());
                      }
                    }
                  },
                ),
              ),
            )
          ],
        ),
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
            AppolloProgressIndicator(),
            AutoSizeText(
              "Please log in using the popup",
              style: MyTheme.textTheme.bodyText2,
            ),
            AutoSizeText("Can't see any popup? Please make sure your browser isn't blocking it.",
                style: MyTheme.textTheme.bodyText2),
          ],
        ),
      ).paddingTop(MyTheme.elementSpacing);
    } else if (state is StateLoadingCreateUser) {
      return SizedBox(
        height: 180,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AppolloProgressIndicator(),
            AutoSizeText(
              "Setting up your account ...",
              style: MyTheme.textTheme.bodyText2,
            ),
          ],
        ),
      ).paddingTop(MyTheme.elementSpacing);
    } else if (state is StateInitial) {
      return Column(
        children: [
          _buildDivider(),
          SizedBox(
            height: getValueForScreenType(
                context: context,
                watch: screenSize.height * 0.08,
                mobile: screenSize.height * 0.08,
                tablet: 0,
                desktop: 0),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  widget.bloc.add(EventGoogleSignIn());
                },
                child: SvgIcon("assets/icons/google_icon.svg", size: 70),
              ),
              SizedBox(
                width: 12,
              ),
              InkWell(
                onTap: () {
                  widget.bloc.add(EventFacebookSignIn());
                },
                child: SvgIcon("assets/icons/facebook_icon.svg", size: 70),
              ),
              SizedBox(
                width: 12,
              ),
              InkWell(
                onTap: () {
                  widget.bloc.add(EventAppleSignIn());
                },
                child: Container(
                    child: SvgIcon("assets/icons/apple_icon.svg", color: MyTheme.textTheme.bodyText2.color, size: 70)),
              ),
            ],
          ).paddingBottom(MyTheme.elementSpacing),
        ],
      ).paddingTop(MyTheme.elementSpacing);
    } else {
      return SizedBox.shrink();
    }
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: MyTheme.appolloPurple, thickness: 0.5)),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: MyTheme.appolloPurple,
          ),
          child: Center(
            child: AutoSizeText(
              "OR",
              style: MyTheme.textTheme.bodyText1.copyWith(color: Colors.white),
            ).paddingAll(8),
          ),
        ).paddingHorizontal(16),
        Expanded(child: Divider(color: MyTheme.appolloPurple, thickness: 0.5)),
      ],
    );
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
      return ReactiveForm(
        formGroup: passwordsForm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildHeadline(state, screenSize),
            SizedBox(
              height: MyTheme.elementSpacing,
            ),
            Container(
              constraints: BoxConstraints(maxWidth: MyTheme.maxWidth),
              child: AppolloTextField(
                formControlName: 'password',
                textFieldType: TextFieldType.reactive,
                autofillHints: [AutofillHints.password],
                validationMessages: (control) => {
                  ValidationMessage.minLength: 'Your password must be at least 8 characters long',
                },
                autofocus: true,
                obscureText: true,
                onFieldSubmitted: (v) {
                  if (passwordsForm.valid) {
                    widget.bloc.add(EventPasswordsConfirmed());
                  } else {
                    passwordsForm.markAllAsTouched();
                  }
                },
                labelText: "Password",
              ),
            ),
            SizedBox(
              height: MyTheme.elementSpacing,
            ),
            Container(
              constraints: BoxConstraints(maxWidth: MyTheme.maxWidth),
              child: AppolloTextField(
                formControlName: 'repeat',
                textFieldType: TextFieldType.reactive,
                autofillHints: [AutofillHints.password],
                validationMessages: (control) => {
                  ValidationMessage.minLength: 'Your password must be at least 8 characters long',
                  ValidationMessage.mustMatch: 'Your passwords must match',
                },
                obscureText: true,
                onFieldSubmitted: (v) {
                  if (passwordsForm.valid) {
                    widget.bloc.add(EventPasswordsConfirmed());
                  } else {
                    passwordsForm.markAllAsTouched();
                  }
                },
                labelText: "Confirm Password",
              ),
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
            height: MyTheme.elementSpacing,
          ),
          ReactiveForm(
            formGroup: loginForm,
            child: Container(
              constraints: BoxConstraints(maxWidth: MyTheme.maxWidth),
              child: AppolloTextField(
                textFieldType: TextFieldType.reactive,
                formControlName: "password",
                autofillHints: [AutofillHints.password],
                obscureText: true,
                labelText: "Password",
                validationMessages: (control) => {
                  ValidationMessage.minLength: 'Your password is at least 8 characters long',
                },
                autofocus: true,
                onFieldSubmitted: (v) {
                  if (state is StateExistingUserEmail) {
                    widget.bloc.add(EventLoginPressed(initialEmailForm.value["email"], loginForm.value["password"]));
                  }
                },
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
                            if (initialEmailForm.value["email"] != "") {
                              AlertGenerator.showAlertWithChoice(
                                      context: context,
                                      title: "Reset your password",
                                      content:
                                          "Need to reset your password? We'll send out an email to ${initialEmailForm.value["email"]} with further instructions",
                                      buttonText1: "Reset",
                                      buttonText2: "Cancel")
                                  .then((value) {
                                if (value != null && value) {
                                  FBServices.instance.resetPassword(initialEmailForm.value["email"]);
                                }
                              });
                            }
                          },
                          child: Text(
                            "FORGOT PASSWORD?",
                            style: MyTheme.textTheme.bodyText2,
                          )),
                    ],
                  ),
                )
              : Container()
        ],
      );
    }
  }

  Widget _buildBackButton(Size screenSize) {
    return ResponsiveBuilder(
      builder: (c, size) {
        if (size.isDesktop || size.isTablet) {
          return SizedBox(
            width: screenSize.width,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: MyTheme.appolloBackgroundColorLight,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
              ),
              child: Text("Back", style: MyTheme.textTheme.button.copyWith(color: MyTheme.appolloGreen)),
              onPressed: () {
                widget.bloc.add(EventChangeEmail());
              },
            ),
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }
}
