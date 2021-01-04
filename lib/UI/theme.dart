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
}

extension AppolloCard on Card {
  Card get appolloCard {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
      elevation: 8,
      shadowColor: Colors.grey[400],
      child: this.child,
    );
  }
}

class MyTheme {
  static final double maxWidth = 800.0;

  static Color appolloPurple = Color(0xFF7367ED);
  static Color appolloYellow = Color(0xFFFBDB30);
  static Color appolloOrange = Color(0xFFFB8F30);
  static Color appolloBlue = Color(0xFF3059FB);
  static Color appolloGreen = Color(0xFF29C66F);
  static Color appolloRed = Color(0xFFEA5454);
  static Color appolloBlack = Color(0xFF2c2c2c);

  static TextTheme mainTT = TextTheme(
      bodyText1:
          TextStyle(fontFamily: "montserrat", fontSize: 16.0, letterSpacing: 0.5, color: appolloBlack).withZoomFix,
      bodyText2:
          TextStyle(fontFamily: "montserrat", fontSize: 14.0, letterSpacing: 0.25, color: appolloBlack).withZoomFix,
      subtitle1: TextStyle(
              fontFamily: "montserrat",
              fontSize: 18.0,
              letterSpacing: 0,
              color: appolloBlack,
              fontWeight: FontWeight.w300)
          .withZoomFix,
      subtitle2: TextStyle(
              fontFamily: "montserrat",
              fontSize: 14.0,
              letterSpacing: 0.25,
              color: appolloBlack,
              fontWeight: FontWeight.w600)
          .withZoomFix,
      headline1: TextStyle(
              fontFamily: "montserrat",
              fontSize: 96.0,
              letterSpacing: -1.5,
              color: appolloBlack,
              fontWeight: FontWeight.w300)
          .withZoomFix,
      headline2: TextStyle(
              fontFamily: "montserrat",
              fontSize: 60.0,
              letterSpacing: -0.5,
              color: appolloBlack,
              fontWeight: FontWeight.w300)
          .withZoomFix,
      headline3: TextStyle(fontFamily: "montserrat", fontSize: 48.0, letterSpacing: 0, color: appolloBlack).withZoomFix,
      headline4: TextStyle(
              fontFamily: "montserrat",
              fontSize: 32.0,
              letterSpacing: 0.25,
              color: appolloBlack,
              fontWeight: FontWeight.w600)
          .withZoomFix,
      headline5: TextStyle(fontFamily: "montserrat", fontSize: 24.0, letterSpacing: 0, color: appolloBlack, fontWeight: FontWeight.w600).withZoomFix,
      headline6: TextStyle(fontFamily: "montserrat", fontSize: 20.0, letterSpacing: 0.25, color: appolloBlack, fontWeight: FontWeight.w600).withZoomFix,
      caption: TextStyle(fontFamily: "montserrat", fontSize: 12.0, letterSpacing: 0.4, color: appolloBlack).withZoomFix,
      button: TextStyle(fontFamily: "montserrat", fontSize: 14.0, letterSpacing: 1.25, color: Colors.white, fontWeight: FontWeight.w600).withZoomFix,
      overline: TextStyle(fontFamily: "montserrat", fontSize: 12.0, letterSpacing: 2, color: appolloBlack).withZoomFix);

  static ThemeData theme = ThemeData(
      backgroundColor: Color(0xfff8f8f8),
      primaryColor: MyTheme.appolloPurple,
      accentColor: MyTheme.appolloPurple,
      buttonColor: MyTheme.appolloPurple,
      primaryIconTheme: IconThemeData(color: MyTheme.appolloPurple),
      navigationRailTheme: NavigationRailThemeData(
          selectedIconTheme: IconThemeData(color: Colors.white),
          unselectedIconTheme: IconThemeData(color: Colors.black)),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: mainTT,
      primaryTextTheme: mainTT);
}
