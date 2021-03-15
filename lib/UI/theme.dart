import 'dart:ui';

import 'package:flutter/material.dart';

extension on TextStyle {
  /// Temporary fix the following Flutter Web issues
  /// https://github.com/flutter/flutter/issues/63467
  /// https://github.com/flutter/flutter/issues/64904#issuecomment-699039851
  /// https://github.com/flutter/flutter/issues/65526
  TextStyle get withZoomFix => copyWith(wordSpacing: 0);
}

extension WidgetPaddingX on Widget {
  Widget paddingTop(double padding) => Padding(
        padding: EdgeInsets.only(top: padding),
        child: this,
      );
  Widget paddingLeft(double padding) => Padding(
        padding: EdgeInsets.only(left: padding),
        child: this,
      );
  Widget paddingRight(double padding) => Padding(
        padding: EdgeInsets.only(right: padding),
        child: this,
      );
  Widget paddingBottom(double padding) => Padding(
        padding: EdgeInsets.only(bottom: padding),
        child: this,
      );
  Widget paddingAll(double padding) => Padding(
        padding: EdgeInsets.all(padding),
        child: this,
      );
  Widget paddingHorizontal(double padding) => Padding(
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: padding),
        child: this,
      );
  Widget paddingVertical(double padding) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: padding),
        child: this,
      );
}

extension AppolloCard on Container {
  Container get appolloCard {
    return Container(
      decoration: ShapeDecoration(
          color: Colors.grey[800].withAlpha(160),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              side: BorderSide(
                  color: Color(0xFF707070).withAlpha(100), width: 1))),
      child: this.child,
    );
  }
}

class MyTheme {
  static double maxWidth = 1050.0;
  static double elementSpacing = 20.0;
  static double cardPadding = 20;
  static double drawerSize = 500;

  static Duration animationDuration = Duration(milliseconds: 300);

  static Color appolloPurple = Color(0xFF7367ED);
  static Color appolloYellow = Color(0xFFFBDB30);
  static Color appolloOrange = Color(0xFFFB8F30);
  static Color appolloBlue = Color(0xFF3059FB);
  static Color appolloLightBlue = Color(0xFF21C0E1);
  static Color appolloGreen = Color(0xFF29C66F);
  static Color appolloRed = Color(0xFFEA5454);
  static Color appolloDarkRed = Color(0xFFFF535E);
  static Color appolloPink = Color(0xFFED67DE);
  static Color appolloBlack = Color(0xFF2c2c2c);
  static Color appolloTeal = Color(0xFF1CD5D0);
  static Color appolloGrey = Color(0xFF707070);
  static Color appolloTextFieldFill = Color(0xFFEFF2F7);
  static Color appolloWhite = Color(0xFFFFFFFF);
  static Color appolloDimGrey = Color(0xFFCDD3E1);
  static Color appolloLightGrey = Color(0xFFEFF2F7);

  static TextTheme lightTextTheme = TextTheme(
      bodyText1: TextStyle(
              fontFamily: "montserrat",
              fontSize: 12.8, // 16
              letterSpacing: 0.5,
              color: appolloWhite,
              fontWeight: FontWeight.w400)
          .withZoomFix,
      bodyText2: TextStyle(
              fontFamily: "montserrat",
              fontSize: 12.8, // 16
              letterSpacing: 0.25,
              color: appolloWhite,
              fontWeight: FontWeight.w400)
          .withZoomFix,
      subtitle1: TextStyle(
              fontFamily: "montserrat",
              fontSize: 14.4, // 18
              letterSpacing: 0.15,
              color: appolloWhite,
              fontWeight: FontWeight.w300)
          .withZoomFix,
      subtitle2: TextStyle(
              fontFamily: "montserrat",
              fontSize: 11.2, // 14
              letterSpacing: 0.1,
              color: appolloWhite,
              fontWeight: FontWeight.w500)
          .withZoomFix,
      headline1: TextStyle(
              fontFamily: "montserrat",
              fontSize: 38.4, // 48
              letterSpacing: -1.0,
              color: appolloWhite,
              fontWeight: FontWeight.w400)
          .withZoomFix,
      headline2: TextStyle(
              fontFamily: "montserrat",
              fontSize: 25.6, // 32
              letterSpacing: -0.5,
              color: appolloWhite,
              fontWeight: FontWeight.w500)
          .withZoomFix,
      headline3: TextStyle(
              fontFamily: "montserrat",
              fontSize: 19.2,
              letterSpacing: 0,
              color: appolloWhite,
              fontWeight: FontWeight.w500) // 24
          .withZoomFix,
      headline4: TextStyle(
              fontFamily: "montserrat",
              fontSize: 19.2,
              letterSpacing: 0,
              color: appolloWhite,
              fontWeight: FontWeight.w400)
          .withZoomFix, // 24
      headline5: TextStyle(
              fontFamily: "montserrat",
              fontSize: 16.0,
              letterSpacing: 0,
              color: appolloWhite,
              fontWeight: FontWeight.w400)
          .withZoomFix, // 20
      headline6: TextStyle(
              fontFamily: "montserrat",
              fontSize: 14.4,
              letterSpacing: 0.25,
              color: appolloWhite,
              fontWeight: FontWeight.w600)
          .withZoomFix, // 16
      caption: TextStyle(
              fontFamily: "montserrat",
              fontSize: 10.8,
              letterSpacing: 0.4,
              color: appolloWhite,
              fontWeight: FontWeight.w400)
          .withZoomFix, // 12
      button: TextStyle(
              fontFamily: "montserrat",
              fontSize: 14,
              letterSpacing: 1.25,
              color: appolloWhite,
              fontWeight: FontWeight.w300)
          .withZoomFix, // 14
      overline: TextStyle(
              fontFamily: "montserrat",
              fontSize: 10.8,
              letterSpacing: 2,
              color: appolloWhite,
              fontWeight: FontWeight.w400)
          .withZoomFix);

  static TextTheme darkTextTheme = TextTheme(
      bodyText1: TextStyle(
              fontFamily: "montserrat",
              fontSize: 12.8, // 16
              letterSpacing: 0.5,
              color: appolloBlack,
              fontWeight: FontWeight.w400)
          .withZoomFix,
      bodyText2: TextStyle(
              fontFamily: "montserrat",
              fontSize: 12.8, // 16
              letterSpacing: 0.25,
              color: appolloBlack,
              fontWeight: FontWeight.w400)
          .withZoomFix,
      subtitle1: TextStyle(
              fontFamily: "montserrat",
              fontSize: 14.4, // 18
              letterSpacing: 0.15,
              color: appolloBlack,
              fontWeight: FontWeight.w300)
          .withZoomFix,
      subtitle2: TextStyle(
              fontFamily: "montserrat",
              fontSize: 11.2, // 14
              letterSpacing: 0.1,
              color: appolloBlack,
              fontWeight: FontWeight.w500)
          .withZoomFix,
      headline1: TextStyle(
              fontFamily: "montserrat",
              fontSize: 38.4, // 48
              letterSpacing: -1.0,
              color: appolloBlack,
              fontWeight: FontWeight.w400)
          .withZoomFix,
      headline2: TextStyle(
              fontFamily: "montserrat",
              fontSize: 25.6, // 32
              letterSpacing: -0.5,
              color: appolloGrey,
              fontWeight: FontWeight.w500)
          .withZoomFix,
      headline3: TextStyle(
              fontFamily: "montserrat",
              fontSize: 19.2,
              letterSpacing: 0,
              color: appolloBlack,
              fontWeight: FontWeight.w500) // 24
          .withZoomFix,
      headline4: TextStyle(
              fontFamily: "montserrat",
              fontSize: 19.2,
              letterSpacing: 0,
              color: appolloGrey,
              fontWeight: FontWeight.w400)
          .withZoomFix, // 24
      headline5: TextStyle(
              fontFamily: "montserrat",
              fontSize: 16.0,
              letterSpacing: 0,
              color: appolloBlack,
              fontWeight: FontWeight.w400)
          .withZoomFix, // 20
      headline6: TextStyle(
              fontFamily: "montserrat",
              fontSize: 14.4,
              letterSpacing: 0.25,
              color: appolloBlack,
              fontWeight: FontWeight.w600)
          .withZoomFix, // 16
      caption: TextStyle(
              fontFamily: "montserrat",
              fontSize: 10.8,
              letterSpacing: 0.4,
              color: appolloBlack,
              fontWeight: FontWeight.w400)
          .withZoomFix, // 12
      button: TextStyle(
              fontFamily: "montserrat",
              fontSize: 14,
              letterSpacing: 1.25,
              color: appolloWhite,
              fontWeight: FontWeight.w300)
          .withZoomFix, // 14
      overline: TextStyle(
              fontFamily: "montserrat",
              fontSize: 10.8,
              letterSpacing: 2,
              color: appolloBlack,
              fontWeight: FontWeight.w400)
          .withZoomFix);

  static ThemeData theme = ThemeData(
      backgroundColor: Color(0xff2c2c2c),
      primaryColor: MyTheme.appolloPurple,
      accentColor: MyTheme.appolloPurple,
      buttonColor: MyTheme.appolloPurple,
      hintColor: MyTheme.appolloWhite,
      canvasColor: Color(0xff2c2c2c),
      inputDecorationTheme: InputDecorationTheme(
          fillColor: Colors.grey[800].withAlpha(50),
          filled: true,
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF707070).withAlpha(80)))),
      primaryIconTheme: IconThemeData(color: MyTheme.appolloPurple),
      navigationRailTheme: NavigationRailThemeData(
          selectedIconTheme: IconThemeData(color: Colors.white),
          unselectedIconTheme: IconThemeData(color: Colors.black)),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: lightTextTheme,
      primaryTextTheme: lightTextTheme);
}
