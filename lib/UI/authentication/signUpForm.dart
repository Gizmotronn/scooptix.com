import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:ticketapp/UI/widgets/textfield/appollo_textfield.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ticketapp/model/user.dart';
import 'package:ticketapp/utilities/alertGenerator.dart';

import '../theme.dart';

class SignUpForm extends StatefulWidget {
  final FormGroup form;
  final TextTheme textTheme;

  const SignUpForm({Key key, @required this.form, @required this.textTheme}) : super(key: key);

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  @override
  Widget build(BuildContext context) {
    return ReactiveForm(
        formGroup: widget.form,
        child: Column(
          crossAxisAlignment: getValueForScreenType(
              context: context,
              watch: CrossAxisAlignment.center,
              mobile: CrossAxisAlignment.center,
              tablet: CrossAxisAlignment.start,
              desktop: CrossAxisAlignment.start),
          children: [
            AutoSizeText(
              "Tell us about yourself",
              textAlign: TextAlign.center,
              style: widget.textTheme.headline4,
            ),
            SizedBox(
              height: MyTheme.elementSpacing * 1.5,
            ),
            AutoSizeText(
              "Name",
              style: widget.textTheme.headline6.copyWith(color: MyTheme.appolloOrange, fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: MyTheme.elementSpacing,
            ),

            Column(
              children: [
                AppolloTextfield(
                  labelText: "First Name",
                  textfieldType: TextFieldType.reactive,
                  formControlName: 'fname',
                  validationMessages: (control) => {
                    ValidationMessage.required: 'Please provide a name',
                  },
                  // decoration: InputDecoration(labelText: "First Name"),
                ),
                SizedBox(
                  height: 8,
                ),
                AppolloTextfield(
                  labelText: "Last Name",
                  textfieldType: TextFieldType.reactive,
                  formControlName: 'lname',
                  validationMessages: (control) => {
                    ValidationMessage.required: 'Please provide a name',
                  },
                  // decoration: InputDecoration(labelText: "Last Name"),
                ),
              ],
            ),

            SizedBox(
              height: MyTheme.elementSpacing * 2,
            ),

            AutoSizeText(
              "Date of birth",
              style: widget.textTheme.headline6.copyWith(color: MyTheme.appolloOrange, fontWeight: FontWeight.w500),
            ),

            SizedBox(
              height: MyTheme.elementSpacing,
            ),
            Column(
              crossAxisAlignment: getValueForScreenType(
                  context: context,
                  watch: CrossAxisAlignment.center,
                  mobile: CrossAxisAlignment.center,
                  tablet: CrossAxisAlignment.start,
                  desktop: CrossAxisAlignment.start),
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: (MyTheme.maxWidth - MyTheme.cardPadding * 4) + 8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: getValueForScreenType(
                            context: context,
                            desktop: MyTheme.drawerSize / 3 - 30,
                            tablet: MyTheme.drawerSize / 3 - 30,
                            mobile: (MyTheme.maxWidth - MyTheme.cardPadding * 4 - 30) / 3,
                            watch: (MyTheme.maxWidth - MyTheme.cardPadding * 4 - 30) / 3),
                        child: AppolloTextfield(
                          labelText: 'Day',
                          textfieldType: TextFieldType.reactive,
                          formControlName: 'dobDay',
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
                            mobile: (MyTheme.maxWidth - MyTheme.cardPadding * 4 - 30) / 3,
                            watch: (MyTheme.maxWidth - MyTheme.cardPadding * 4 - 30) / 3),
                        child: AppolloTextfield(
                          labelText: 'Month',
                          textfieldType: TextFieldType.reactive,
                          formControlName: 'dobMonth',
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
                            mobile: (MyTheme.maxWidth - MyTheme.cardPadding * 4 - 30) / 3,
                            watch: (MyTheme.maxWidth - MyTheme.cardPadding * 4 - 30) / 3),
                        child: AppolloTextfield(
                          labelText: 'Year',
                          textfieldType: TextFieldType.reactive,
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
                  height: MyTheme.elementSpacing * 2,
                ),
                AutoSizeText(
                  "Gender",
                  style: widget.textTheme.headline6.copyWith(color: MyTheme.appolloOrange, fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: MyTheme.elementSpacing,
                ),
                SizedBox(
                  width: (MyTheme.maxWidth - MyTheme.cardPadding * 4) + 8,
                  child: ReactiveDropdownField(
                    isDense: true,
                    formControlName: 'gender',
                    decoration: InputDecoration(),
                    items: [Gender.Female, Gender.Male, Gender.Other].map((e) {
                      return DropdownMenuItem(
                        value: e,
                        child: Text(
                          e.toDisplayString(),
                          style: widget.textTheme.bodyText1,
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
              style: widget.textTheme.headline6.copyWith(color: MyTheme.appolloOrange, fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: MyTheme.elementSpacing,
            ),
            AutoSizeText(
              "We require this information to issue your ticket. Please note that providing incorrect information may invalidate you ticket.\n\nWe’ll save this data for you so you’ll only need to provide it once. ",
              style: widget.textTheme.caption,
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
                            const url = 'https://appollo.io/terms-of-service.html';
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
                        style: widget.textTheme.bodyText2.copyWith(decoration: TextDecoration.underline),
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
