import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:ui_basics/ui_basics.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ticketapp/model/user.dart';
import 'package:ticketapp/utilities/alert_generator.dart';

import '../../UI/theme.dart';

class SignUpForm extends StatefulWidget {
  final FormGroup form;

  const SignUpForm({Key? key, required this.form}) : super(key: key);

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  @override
  Widget build(BuildContext context) {
    return ReactiveForm(
        formGroup: widget.form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutoSizeText(
              "Create an account",
              textAlign: TextAlign.center,
              style: getValueForScreenType(
                  context: context,
                  watch: MyTheme.textTheme.headline5!.copyWith(color: MyTheme.scoopGreen),
                  mobile: MyTheme.textTheme.headline5!.copyWith(color: MyTheme.scoopGreen),
                  tablet: MyTheme.textTheme.headline4!.copyWith(color: MyTheme.scoopGreen),
                  desktop: MyTheme.textTheme.headline4!.copyWith(color: MyTheme.scoopGreen)),
            ).paddingBottom(MyTheme.elementSpacing),
            AutoSizeText(
              "Tell us about yourself",
              textAlign: TextAlign.center,
              style: getValueForScreenType(
                  context: context,
                  watch: MyTheme.textTheme.headline5!.copyWith(color: MyTheme.scoopGreen),
                  mobile: MyTheme.textTheme.headline5!.copyWith(color: MyTheme.scoopGreen),
                  tablet: MyTheme.textTheme.headline4!.copyWith(color: MyTheme.scoopGreen),
                  desktop: MyTheme.textTheme.headline4!.copyWith(color: MyTheme.scoopGreen)),
            ).paddingBottom(MyTheme.elementSpacing),

            Column(
              children: [
                ScoopTextField.reactive(
                  labelText: "First Name",
                  formControl: widget.form.controls['fname'],
                  validationMessages: (control) => {
                    ValidationMessage.required: 'Please provide a name',
                  },
                  // decoration: InputDecoration(labelText: "First Name"),
                ).paddingBottom(MyTheme.elementSpacing),
                ScoopTextField.reactive(
                  labelText: "Last Name",
                  formControl: widget.form.controls['lname'],
                  validationMessages: (control) => {
                    ValidationMessage.required: 'Please provide a name',
                  },
                  // decoration: InputDecoration(labelText: "Last Name"),
                ),
              ],
            ).paddingBottom(MyTheme.elementSpacing * 2),

            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AutoSizeText(
                  "Date of Birth",
                  style: MyTheme.textTheme.headline5!.copyWith(color: MyTheme.scoopOrange, fontWeight: FontWeight.w500),
                ).paddingBottom(MyTheme.elementSpacing),
                SizedBox(
                  width: (MyTheme.maxWidth - MyTheme.elementSpacing * 4) + 8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: getValueForScreenType(
                            context: context,
                            desktop: MyTheme.drawerSize / 3 - 30,
                            tablet: MyTheme.drawerSize / 3 - 30,
                            mobile: ((MyTheme.maxWidth - MyTheme.elementSpacing * 4) + 8) / 3,
                            watch: ((MyTheme.maxWidth - MyTheme.elementSpacing * 4) + 8) / 3),
                        child: ScoopTextField.reactive(
                          labelText: 'Day',
                          formControl: widget.form.controls["dobDay"],
                          keyboardType: TextInputType.number,
                          validationMessages: (control) => {
                            ValidationMessage.required: 'Please provide a day',
                            ValidationMessage.max: 'Please provide a valid day',
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          /*
                          decoration: InputDecoration(
                            hintText: "DD",
                            labelText: 'Day',
                          ),
                          */
                        ),
                      ),
                      SizedBox(
                        width: getValueForScreenType(
                            context: context,
                            desktop: MyTheme.drawerSize / 3 - 30,
                            tablet: MyTheme.drawerSize / 3 - 30,
                            mobile: ((MyTheme.maxWidth - MyTheme.elementSpacing * 4) + 8) / 3,
                            watch: ((MyTheme.maxWidth - MyTheme.elementSpacing * 4) + 8) / 3),
                        child: ScoopTextField.reactive(
                          labelText: 'Month',
                          formControl: widget.form.controls["dobMonth"],
                          validationMessages: (control) => {
                            ValidationMessage.required: 'Please provide a month',
                            ValidationMessage.max: 'Please provide a valid month',
                          },
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          /* decoration: InputDecoration(
                            hintText: "MM",
                            labelText: 'Month',
                          ),
                          */
                        ),
                      ),
                      SizedBox(
                        width: getValueForScreenType(
                            context: context,
                            desktop: MyTheme.drawerSize / 3 - 30,
                            tablet: MyTheme.drawerSize / 3 - 30,
                            mobile: ((MyTheme.maxWidth - MyTheme.elementSpacing * 4) + 8) / 3,
                            watch: ((MyTheme.maxWidth - MyTheme.elementSpacing * 4) + 8) / 3),
                        child: ScoopTextField.reactive(
                          labelText: 'Year',
                          formControl: widget.form.controls["dobYear"],
                          validationMessages: (control) => {
                            ValidationMessage.required: 'Please provide a year',
                            ValidationMessage.max: 'Please provide a valid year',
                            ValidationMessage.min: 'Please provide a valid year',
                          },
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          /*decoration: InputDecoration(
                            hintText: "YYYY",
                            labelText: 'Year',
                          ),
                          */
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MyTheme.elementSpacing,
                ),
                SizedBox(
                  width: (MyTheme.maxWidth - MyTheme.elementSpacing * 2) + 8,
                  child: ReactiveDropdownField(
                    isDense: true,
                    formControlName: 'gender',
                    decoration: InputDecoration(),
                    items: [Gender.Female, Gender.Male, Gender.Other].map((e) {
                      return DropdownMenuItem(
                        value: e,
                        child: Text(
                          e.toDisplayString(),
                          style: MyTheme.textTheme.bodyText1,
                        ),
                      );
                    }).toList(),
                  ),
                )
              ],
            ),

            SizedBox(
              height: MyTheme.elementSpacing * 2,
            ),
            AutoSizeText(
              "Terms & Conditions",
              style: MyTheme.textTheme.headline5!.copyWith(color: MyTheme.scoopOrange, fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: MyTheme.elementSpacing,
            ),
            AutoSizeText(
              "We require this information to issue your ticket. Please note that providing incorrect information may invalidate you ticket.\n\nWe???ll save this data for you so you???ll only need to provide it once. ",
              style: MyTheme.textTheme.caption,
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: MyTheme.elementSpacing,
            ),
            SizedBox(
              width: MyTheme.maxWidth,
              child: Row(
                children: [
                  ReactiveCheckbox(
                    formControlName: "terms",
                  ).paddingRight(8),
                  InkWell(
                      onTap: () {
                        AlertGenerator.showAlertWithChoice(
                                context: context,
                                title: "View Terms & Conditions",
                                content: "The Terms & Conditions will be shown on a new page, do you want to continue?",
                                buttonText1: "Show T&C",
                                buttonText2: "Cancel")
                            .then((value) async {
                          if (value != null && value) {
                            const url = 'https://scooptix.com/terms-of-service.html';
                            if (await canLaunch(url)) {
                              await launch(url);
                            } else {
                              throw 'Could not launch $url';
                            }
                          }
                        });
                      },
                      child: Text(
                        "I accept the terms & conditions",
                        style: MyTheme.textTheme.bodyText2!.copyWith(decoration: TextDecoration.underline),
                      )),
                ],
              ),
            ),
            SizedBox(
              height: MyTheme.elementSpacing * 1.5,
            ),
            // _buildMainButtons(state, screenSize),
          ],
        ));
  }
}
