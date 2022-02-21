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

extension AppolloCards on Container {
  Container appolloBlurCard({Color? color, BorderRadius? borderRadius, Clip? clip}) {
    return Container(
      child: ClipRRect(
        clipBehavior: clip ?? Clip.antiAlias,
        borderRadius: borderRadius ?? BorderRadius.all(Radius.circular(5)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Container(
            decoration: ShapeDecoration(
              color: color ?? MyTheme.scoopBackgroundColor.withAlpha(90),
              shape: RoundedRectangleBorder(borderRadius: borderRadius ?? BorderRadius.all(Radius.circular(16))),
            ),
            child: this.child,
          ),
        ),
      ),
    );
  }

  Container appolloCard({Color? color, BorderRadius? borderRadius}) {
    return Container(
      decoration: ShapeDecoration(
          color: color ?? MyTheme.scoopCardColor,
          shape: RoundedRectangleBorder(borderRadius: borderRadius ?? BorderRadius.all(Radius.circular(5)))),
      child: this.child,
    );
  }
}

class MyTheme {
  static double maxWidth = 1150.0;
  static double elementSpacing = 20.0;
  static double cardPadding = 32;
  static double drawerSize = 432;
  static double bottomNavBarHeight = 64;
  static double appBarHeight = 74;

  static Duration animationDuration = Duration(milliseconds: 300);

  static Color scoopPurple = Color(0xFF7367ED);
  static Color scoopYellow = Color(0xFFFBDB30);
  static Color scoopOrange = Color(0xFFFB8F30);
  static Color scoopBlue = Color(0xFF3059FB);
  static Color scoopLightBlue = Color(0xFF21C0E1);
  static Color scoopGreen = Color(0xFF29C66F);
  static Color scoopRed = Color(0xFFEA5454);
  static Color scoopDarkRed = Color(0xFFFF535E);
  static Color scoopPink = Color(0xFFED67DE);
  static Color scoopBlack = Color(0xFF111010);
  static Color scoopTeal = Color(0xFF1CD5D0);
  static Color scoopGrey = Color(0xFF707070);
  static Color scoopTextFieldFill = Color(0xFFEFF2F7);
  static Color scoopWhite = Color(0xFFFFFFFF);
  static Color scoopDimGrey = Color(0xFFCDD3E1);
  static Color scoopLightGrey = Color(0xFFEFF2F7);
  static Color scoopBackgroundColor = Color(0xFF14142B);
  static Color scoopBackgroundColorLight = Color(0xFF21223B);
  static Color scoopLightCardColor = Color(0xFF4D4D7E);
  static Color scoopCardColor = Color(0xFF2B2B57);
  static Color scoopCardColorLight = Color(0xFF343454);
  static Color scoopTextFieldColor = Color(0xFF282840);
  static Color scoopBottomBarColor = Color(0xFF383854);

  static TextTheme textTheme = TextTheme(
      bodyText1: TextStyle(
              fontFamily: "montserrat",
              fontSize: 13.6, // 16
              letterSpacing: 0.5,
              color: scoopWhite,
              fontWeight: FontWeight.w500)
          .withZoomFix,
      bodyText2: TextStyle(
              fontFamily: "montserrat",
              fontSize: 11.9, // 16
              letterSpacing: 0.25,
              color: scoopWhite,
              fontWeight: FontWeight.w500)
          .withZoomFix,
      subtitle1: TextStyle(
              fontFamily: "montserrat",
              fontSize: 15.3, // 18
              letterSpacing: 0.15,
              color: scoopWhite,
              fontWeight: FontWeight.w500)
          .withZoomFix,
      subtitle2: TextStyle(
              fontFamily: "montserrat",
              fontSize: 11.2, // 14
              letterSpacing: 0.1,
              color: scoopWhite,
              fontWeight: FontWeight.w500)
          .withZoomFix,
      headline1: TextStyle(
              fontFamily: "montserrat",
              fontSize: 38.4, // 48
              letterSpacing: -1.0,
              color: scoopWhite,
              fontWeight: FontWeight.w400)
          .withZoomFix,
      headline2: TextStyle(
              fontFamily: "montserrat",
              fontSize: 27.2, // 32
              letterSpacing: -0.25,
              color: scoopWhite,
              fontWeight: FontWeight.w400)
          .withZoomFix,
      headline3: TextStyle(
              fontFamily: "montserrat",
              fontSize: 19.2,
              letterSpacing: 0,
              color: scoopGreen,
              fontWeight: FontWeight.w500) // 24
          .withZoomFix,
      headline4: TextStyle(
              fontFamily: "montserrat",
              fontSize: 20.4,
              letterSpacing: 0,
              color: scoopWhite,
              fontWeight: FontWeight.w400)
          .withZoomFix, // 24
      headline5: TextStyle(
              fontFamily: "montserrat",
              fontSize: 17.0,
              letterSpacing: 0.25,
              color: scoopWhite,
              fontWeight: FontWeight.w400)
          .withZoomFix, // 20
      headline6: TextStyle(
              fontFamily: "montserrat",
              fontSize: 17,
              letterSpacing: 0.25,
              color: scoopWhite,
              fontWeight: FontWeight.w400)
          .withZoomFix, // 16
      caption: TextStyle(
              fontFamily: "montserrat",
              fontSize: 10.8,
              letterSpacing: 0.4,
              color: scoopWhite,
              fontWeight: FontWeight.w400)
          .withZoomFix, // 12
      button: TextStyle(
              fontFamily: "montserrat",
              fontSize: 16,
              letterSpacing: 0.75,
              color: scoopBackgroundColor,
              fontWeight: FontWeight.w500)
          .withZoomFix, // 14
      overline: TextStyle(
              fontFamily: "montserrat",
              fontSize: 10.8,
              letterSpacing: 0.5,
              color: scoopWhite,
              fontWeight: FontWeight.w400)
          .withZoomFix);

  static TextTheme mobileTextTheme = TextTheme(
      bodyText1: TextStyle(
              fontFamily: "montserrat",
              fontSize: 13.6, // 16
              letterSpacing: 0.5,
              color: scoopWhite,
              fontWeight: FontWeight.w500)
          .withZoomFix,
      bodyText2: TextStyle(
              fontFamily: "montserrat",
              fontSize: 11.9, // 16
              letterSpacing: 0.25,
              color: scoopWhite,
              fontWeight: FontWeight.w500)
          .withZoomFix,
      subtitle1: TextStyle(
              fontFamily: "montserrat",
              fontSize: 15.3, // 18
              letterSpacing: 0.15,
              color: scoopWhite,
              fontWeight: FontWeight.w500)
          .withZoomFix,
      subtitle2: TextStyle(
              fontFamily: "montserrat",
              fontSize: 11.2, // 14
              letterSpacing: 0.1,
              color: scoopWhite,
              fontWeight: FontWeight.w500)
          .withZoomFix,
      headline1: TextStyle(
              fontFamily: "montserrat",
              fontSize: 38.4, // 48
              letterSpacing: -1.0,
              color: scoopWhite,
              fontWeight: FontWeight.w400)
          .withZoomFix,
      headline2: TextStyle(
              fontFamily: "montserrat",
              fontSize: 27.2, // 32
              letterSpacing: -0.25,
              color: scoopWhite,
              fontWeight: FontWeight.w400)
          .withZoomFix,
      headline3: TextStyle(
              fontFamily: "montserrat",
              fontSize: 21,
              letterSpacing: 0,
              color: scoopWhite,
              fontWeight: FontWeight.w600) // 24
          .withZoomFix,
      headline4: TextStyle(
              fontFamily: "montserrat",
              fontSize: 20.4,
              letterSpacing: 0,
              color: scoopWhite,
              fontWeight: FontWeight.w400)
          .withZoomFix, // 24
      headline5: TextStyle(
              fontFamily: "montserrat",
              fontSize: 18.0,
              letterSpacing: 0,
              color: scoopWhite,
              fontWeight: FontWeight.w600)
          .withZoomFix, // 20
      headline6: TextStyle(
              fontFamily: "montserrat",
              fontSize: 17,
              letterSpacing: 0.25,
              color: scoopWhite,
              fontWeight: FontWeight.w400)
          .withZoomFix, // 16
      caption: TextStyle(
              fontFamily: "montserrat",
              fontSize: 10.8,
              letterSpacing: 0.4,
              color: scoopWhite,
              fontWeight: FontWeight.w400)
          .withZoomFix, // 12
      button: TextStyle(
              fontFamily: "montserrat",
              fontSize: 19,
              letterSpacing: 0.75,
              color: scoopBackgroundColor,
              fontWeight: FontWeight.w500)
          .withZoomFix, // 14
      overline: TextStyle(
              fontFamily: "montserrat",
              fontSize: 10.8,
              letterSpacing: 0.5,
              color: scoopWhite,
              fontWeight: FontWeight.w400)
          .withZoomFix);

  static ThemeData theme = ThemeData(
      backgroundColor: Color(0xFF21223B),
      scaffoldBackgroundColor: Color(0xFF21223B),
      primaryColor: MyTheme.scoopGreen,
      accentColor: MyTheme.scoopGreen,
      buttonColor: MyTheme.scoopGreen,
      hintColor: MyTheme.scoopWhite,
      indicatorColor: MyTheme.scoopGreen,
      splashColor: MyTheme.scoopGreen,
      canvasColor: Color(0xff2c2c2c),
      inputDecorationTheme: InputDecorationTheme(
          fillColor: Colors.grey[800]!.withAlpha(50),
          filled: true,
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF707070).withAlpha(80)))),
      primaryIconTheme: IconThemeData(color: MyTheme.scoopGreen),
      navigationRailTheme: NavigationRailThemeData(
          selectedIconTheme: IconThemeData(color: Colors.white),
          unselectedIconTheme: IconThemeData(color: Colors.black)),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      unselectedWidgetColor: MyTheme.scoopWhite,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      textSelectionTheme: TextSelectionThemeData(cursorColor: MyTheme.scoopGreen));
}
