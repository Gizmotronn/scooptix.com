import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:ticketapp/pages/authentication/sign_up_form.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/appollo/appollo_progress_indicator.dart';
import 'package:ticketapp/main.dart';
import 'package:ticketapp/model/user.dart';
import 'package:ticketapp/services/firebase.dart';
import 'package:ticketapp/utilities/alert_generator.dart';
import 'package:ui_basics/ui_basics.dart';
import 'bloc/authentication_bloc.dart';

class LoginAndSignupPage extends StatefulWidget {
  static const String routeName = '/loginSignUp';

  final AuthenticationBloc bloc;

  const LoginAndSignupPage({Key? key, required this.bloc}) : super(key: key);

  @override
  _LoginAndSignupPageState createState() => _LoginAndSignupPageState();
}

class _LoginAndSignupPageState extends State<LoginAndSignupPage> {
  late FormGroup form;
  late FormGroup passwordsForm;
  late FormGroup initialEmailForm;
  late FormGroup confirmEmailForm;
  late FormGroup loginForm;

  final int animationTime = 400;

  bool _termsAccepted = false;

  @override
  void initState() {
    form = FormGroup({
      'fname': FormControl<String>(validators: [Validators.required]),
      'lname': FormControl<String>(validators: [Validators.required]),
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
      child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          bloc: widget.bloc,
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
            } else if (state is StateLoadingCreateUser) {
              return SizedBox(
                  height: screenSize.height,
                  width: MyTheme.drawerSize,
                  child: Center(child: AppolloProgressIndicator()));
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
            child: ScoopButton(
              leadingOnly: true,
              buttonTheme: ScoopButtonTheme.secondary,
              fill: ButtonFill.filled,
              minWidth: 130,
              maxWidth: 130,
              leading: FittedBox(
                fit: BoxFit.scaleDown,
                child: ScoopButtonProgressIndicator(),
              ),
              onTap: () {},
            ),
          );
        } else {
          return Align(
            alignment: Alignment.centerRight,
            child: ScoopButton(
              leadingOnly: true,
              buttonTheme: ScoopButtonTheme.secondary,
              fill: ButtonFill.filled,
              minWidth: 130,
              maxWidth: 130,
              leading: FittedBox(
                fit: BoxFit.scaleDown,
                child: ScoopButtonProgressIndicator(),
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
                child: ScoopButton(
                  buttonTheme: ScoopButtonTheme.secondary,
                  title: "Login",
                  onTap: () {
                    widget.bloc.add(EventLoginPressed(
                        initialEmailForm.value["email"] as String, loginForm.value["password"] as String));
                  },
                ),
              ).paddingBottom(8),
            ],
          );
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ScoopButton(
                fill: ButtonFill.outlined,
                buttonTheme: ScoopButtonTheme.secondary,
                title: "Back",
                minWidth: 130,
                maxWidth: 130,
                onTap: () {
                  widget.bloc.add(EventChangeEmail());
                },
              ),
              ScoopButton(
                title: "Login",
                minWidth: 130,
                maxWidth: 130,
                buttonTheme: ScoopButtonTheme.secondary,
                onTap: () {
                  widget.bloc.add(EventLoginPressed(
                      initialEmailForm.value["email"] as String, loginForm.value["password"] as String));
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
                child: ScoopButton(
                  title: "Next",
                  minWidth: 130,
                  maxWidth: 130,
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
              ScoopButton(
                fill: ButtonFill.outlined,
                buttonTheme: ScoopButtonTheme.secondary,
                minWidth: 130,
                maxWidth: 130,
                title: "Back",
                onTap: () {
                  widget.bloc.add(EventChangeEmail());
                },
              ),
              ScoopButton(
                fill: ButtonFill.filled,
                buttonTheme: ScoopButtonTheme.secondary,
                title: "Next",
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
    } else if (state is StateNewUserEmail) {
      return ResponsiveBuilder(builder: (context, constraints) {
        if (constraints.deviceScreenType == DeviceScreenType.mobile ||
            constraints.deviceScreenType == DeviceScreenType.watch) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: screenSize.width,
                child: ScoopButton(
                  title: "Next",
                  buttonTheme: ScoopButtonTheme.secondary,
                  fill: ButtonFill.filled,
                  minWidth: 130,
                  maxWidth: 130,
                  onTap: () {
                    if (!confirmEmailForm.hasErrors) {
                      widget.bloc.add(EventEmailsConfirmed());
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
              ScoopButton(
                fill: ButtonFill.outlined,
                title: "Back",
                buttonTheme: ScoopButtonTheme.secondary,
                minWidth: 130,
                maxWidth: 130,
                onTap: () {
                  widget.bloc.add(EventChangeEmail());
                },
              ),
              ScoopButton(
                title: "Next",
                onTap: () {
                  if (!confirmEmailForm.hasErrors) {
                    widget.bloc.add(EventEmailsConfirmed());
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
            child: ScoopButton(
              buttonTheme: ScoopButtonTheme.secondary,
              title: "Next",
              onTap: () {
                initialEmailForm.markAllAsTouched();
                if (!initialEmailForm.hasErrors) {
                  setState(() {
                    confirmEmailForm.controls["email"]!.value = initialEmailForm.value["email"];
                  });
                  widget.bloc.add(EventEmailProvided(initialEmailForm.value["email"]! as String));
                }
              },
            ),
          ).paddingBottom(8).paddingTop(MyTheme.elementSpacing);
        } else {
          return Align(
            alignment: Alignment.centerRight,
            child: ScoopButton(
              buttonTheme: ScoopButtonTheme.secondary,
              fill: ButtonFill.filled,
              minWidth: 130,
              maxWidth: 130,
              leadingOnly: state is StateLoadingUserData,
              leading: state is StateLoadingUserData
                  ? SizedBox(
                      height: 18,
                      width: 34,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: ScoopButtonProgressIndicator(),
                      ),
                    )
                  : null,
              title: "Next",
              onTap: () {
                initialEmailForm.markAllAsTouched();
                if (!initialEmailForm.hasErrors) {
                  setState(() {
                    confirmEmailForm.controls["email"]!.value = initialEmailForm.value["email"];
                  });
                  widget.bloc.add(EventEmailProvided(initialEmailForm.value["email"] as String));
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
                child: ScoopButton(
                  buttonTheme: ScoopButtonTheme.secondary,
                  title: "Register",
                  onTap: () {
                    if (form.valid) {
                      try {
                        DateTime dob = DateTime(form.controls["dobYear"]!.value as int,
                            form.controls["dobMonth"]!.value as int, form.controls["dobDay"]!.value as int);
                        widget.bloc.add(EventCreateNewUser(
                            confirmEmailForm.value["email"] as String,
                            passwordsForm.value["password"] as String,
                            form.controls["fname"]!.value as String,
                            form.controls["lname"]!.value as String,
                            dob,
                            form.controls["gender"]!.value as Gender,
                            state.uid));
                      } catch (_) {}
                    } else {
                      form.markAllAsTouched();

                      if (!_termsAccepted) {
                        AlertGenerator.showAlert(
                            context: WrapperPage.mainScaffold.currentContext!,
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
              ScoopButton(
                fill: ButtonFill.outlined,
                buttonTheme: ScoopButtonTheme.secondary,
                minWidth: 130,
                maxWidth: 130,
                title: "Back",
                onTap: () {
                  widget.bloc.add(EventChangeEmail());
                },
              ),
              ScoopButton(
                fill: ButtonFill.filled,
                buttonTheme: ScoopButtonTheme.secondary,
                title: "Register",
                minWidth: 130,
                maxWidth: 130,
                onTap: () {
                  if (form.valid) {
                    try {
                      DateTime dob = DateTime(form.controls["dobYear"]!.value as int,
                          form.controls["dobMonth"]!.value as int, form.controls["dobDay"]!.value as int);
                      widget.bloc.add(EventCreateNewUser(
                          confirmEmailForm.value["email"] as String,
                          passwordsForm.value["password"] as String,
                          form.controls["fname"]!.value as String,
                          form.controls["lname"]!.value as String,
                          dob,
                          form.controls["gender"]!.value as Gender,
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
    } else if (state is StateNewUserEmail) {
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
                  style: MyTheme.textTheme.headline5!.copyWith(color: MyTheme.scoopGreen),
                ).paddingBottom(MyTheme.elementSpacing);
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      "Sign up or sign in",
                      style: MyTheme.textTheme.headline2!.copyWith(color: MyTheme.scoopWhite),
                    ).paddingBottom(MyTheme.elementSpacing * 2),
                    AutoSizeText(
                      "Let's start with your email.",
                      style: MyTheme.textTheme.headline4!.copyWith(color: MyTheme.scoopGreen),
                    ),
                  ],
                ).paddingBottom(MyTheme.elementSpacing * 0.5);
              }
            }),
            AutoSizeText(
              "Welcome, please enter your email to continue.",
              style: MyTheme.textTheme.bodyText2!.copyWith(
                color: state is StateLoginFailed ? MyTheme.scoopRed : MyTheme.scoopWhite,
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
          style: MyTheme.textTheme.headline5!
              .copyWith(color: state is StateLoginFailed ? MyTheme.scoopRed : MyTheme.scoopGreen),
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
          constraints: BoxConstraints(maxWidth: MyTheme.maxWidth),
          child: ScoopTextField.reactive(
            formControl: initialEmailForm.controls["email"],
            keyboardType: TextInputType.emailAddress,
            autofillHints: [AutofillHints.email, AutofillHints.username],
            validationMessages: (control) => {
              ValidationMessage.required: 'Please provide an email',
              ValidationMessage.email: 'Please provide a valid email',
            },
            onFieldSubmitted: () {
              initialEmailForm.markAllAsTouched();
              if (!initialEmailForm.hasErrors) {
                setState(() {
                  confirmEmailForm.controls["email"]!.value = initialEmailForm.value["email"];
                });
                widget.bloc.add(EventEmailProvided(initialEmailForm.value["email"] as String));
              }
            },
            labelText: "Email",
          ),
        ),
      );
    // Prompt confirm email
    else if (state is StateNewUserEmail) {
      return ReactiveForm(
        formGroup: confirmEmailForm,
        child: Column(
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: MyTheme.maxWidth),
              child: Focus(
                child: ScoopTextField.reactive(
                  formControl: confirmEmailForm.controls["email"],
                  labelText: "Email",
                  keyboardType: TextInputType.emailAddress,
                  validationMessages: (control) => {
                    ValidationMessage.required: 'Please provide an email',
                    ValidationMessage.email: 'Please provide a valid email',
                  },
                  autofillHints: [AutofillHints.email, AutofillHints.newUsername],
                  onFieldSubmitted: () {
                    if (!confirmEmailForm.hasErrors) {
                      widget.bloc.add(EventEmailsConfirmed());
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
                child: ScoopTextField.reactive(
                  labelText: "Confirm Email",
                  keyboardType: TextInputType.emailAddress,
                  validationMessages: (control) => {
                    ValidationMessage.required: 'Please provide an email',
                    ValidationMessage.email: 'Please provide a valid email',
                    ValidationMessage.mustMatch: "Emails must match"
                  },
                  formControl: confirmEmailForm.controls["repeat"],
                  autofillHints: [AutofillHints.email, AutofillHints.newUsername],
                  autofocus: true,
                  onFieldSubmitted: () {
                    if (!confirmEmailForm.hasErrors) {
                      widget.bloc.add(EventEmailsConfirmed());
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

  bool showSSOInfo = false;

  /// Builds TextInputFields for the initial email fields as well as email and password confirmation
  _buildEmailAndPWFields(AuthenticationState state, Size screenSize) {
    if (state is StateLoadingCreateUser) {
      return Container();
    } else if (state is StateNewUserEmail) {
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
              child: ScoopTextField.reactive(
                formControl: passwordsForm.controls['password'],
                autofillHints: [AutofillHints.newPassword],
                validationMessages: (control) => {
                  ValidationMessage.minLength: 'Your password must be at least 8 characters long',
                },
                autofocus: true,
                obscureText: true,
                onFieldSubmitted: () {
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
              child: ScoopTextField.reactive(
                formControl: passwordsForm.controls['repeat'],
                autofillHints: [AutofillHints.newPassword],
                validationMessages: (control) => {
                  ValidationMessage.minLength: 'Your password must be at least 8 characters long',
                  ValidationMessage.mustMatch: 'Your passwords must match',
                },
                obscureText: true,
                onFieldSubmitted: () {
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
              child: ScoopTextField.reactive(
                formControl: loginForm.controls["password"],
                autofillHints: [AutofillHints.password],
                obscureText: true,
                labelText: "Password",
                validationMessages: (control) => {
                  ValidationMessage.minLength: 'Your password is at least 8 characters long',
                },
                autofocus: true,
                onFieldSubmitted: () {
                  if (state is StateExistingUserEmail) {
                    widget.bloc.add(EventLoginPressed(
                        initialEmailForm.value["email"] as String, loginForm.value["password"] as String));
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
                                  FBServices.instance.resetPassword(initialEmailForm.value["email"] as String);
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
            child: ScoopButton(
              buttonTheme: ScoopButtonTheme.secondary,
              fill: ButtonFill.outlined,
              title: "Back",
              onTap: () {
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
