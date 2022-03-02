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
  Widget paddingVertical(double padding) => Padding(
        padding: EdgeInsets.symmetric(vertical: padding),
        child: this,
      );
  Widget paddingHorizontal(double padding) => Padding(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: this,
      );
}

class MyTheme {
  static const Color primaryMain = Color(0xFFFF9F45);
  static const Color primaryOff = Color(0xFFFFAC66);
  static const Color secondaryMain = Color(0xFF29C66F);
  static const Color secondaryOff = Color(0xFF5DFAA3);
  static const Color background = Color(0xFF14142B);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightBackground = Color(0xFF21223B);
  static const Color darkRed = Color(0xFFFF535E);
  static const Color grey = Color(0xFF707070);
  static const Color black = Color(0xFF2c2c2c);
  static const Color dimGrey = Color(0xFFCDD3E1);
  static const Color unselectedGrey = Color(0xFFA0A3BD);
  static const Color cardColor = Color(0xFF2B2B57);

  static const double elementSpacing = 16.0;
  static Duration animationDuration = const Duration(milliseconds: 300);
  static const double textFontSize = 13.5;

  static TextStyle button = const TextStyle(
          fontFamily: "montserrat", fontSize: 15, letterSpacing: 0.75, color: Colors.white, fontWeight: FontWeight.w600)
      .withZoomFix;

  static TextStyle dropdownTitle = const TextStyle(
          fontFamily: "montserrat", fontSize: 12.5, letterSpacing: 0.15, color: white, fontWeight: FontWeight.w600)
      .withZoomFix;

  static TextStyle dropdownElement = const TextStyle(
          fontFamily: "montserrat",
          fontSize: 13.5, // 18
          letterSpacing: 0.15,
          color: white,
          fontWeight: FontWeight.w300)
      .withZoomFix;

  static TextStyle label = const TextStyle(
          fontFamily: "montserrat",
          fontSize: 12, // 16
          letterSpacing: 0.5,
          color: white,
          fontWeight: FontWeight.w500)
      .withZoomFix;

  static TextStyle hint = const TextStyle(
          fontFamily: "montserrat",
          fontSize: 12, // 16
          letterSpacing: 0,
          color: white,
          fontWeight: FontWeight.w400)
      .withZoomFix;

  static TextStyle error = const TextStyle(
          fontFamily: "montserrat", fontSize: 10.5, letterSpacing: 0.4, color: darkRed, fontWeight: FontWeight.w400)
      .withZoomFix;
}
