import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:ticketapp/UI/theme.dart';

class AppolloButton {
  static smallRaisedButton(
          {@required Widget child,
          @required Function onTap,
          Color color = Colors.white}) =>
      Container(
          constraints: BoxConstraints(
            minHeight: 40,
            maxHeight: 40,
            minWidth: 130,
            maxWidth: 200,
          ),
          child: RaisedButton(
            elevation: 3,
            color: color,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            onPressed: onTap,
            child: child,
          ));

  static smallButton(
          {@required Widget child,
          double labelSize,
          Color color,
          @required Function onTap,
          bool fill = true,
          bool border = true}) =>
      ResponsiveBuilder(builder: (context, SizingInformation size) {
        return Container(
          constraints: BoxConstraints(
            minHeight: size.isDesktop ? 40 : 25,
            maxHeight: size.isDesktop ? 40 : 25,
            minWidth: 130,
            maxWidth: 200,
          ),
          child: FlatButton(
            color: fill
                ? color ?? MyTheme.theme.buttonColor
                : MyTheme.theme.buttonColor.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
              side: BorderSide(
                  color: MyTheme.theme.buttonColor, width: border ? 1.3 : 0),
            ),
            onPressed: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: child,
            ),
          ),
        );
      });
  static mediumButton(
          {@required Widget child,
          double labelSize,
          Color color,
          @required Function onTap,
          bool fill = true,
          bool border = true}) =>
      Container(
        constraints: BoxConstraints(
          minHeight: 50,
          maxHeight: 50,
          minWidth: 130,
          maxWidth: 200,
        ),
        child: FlatButton(
          color: fill
              ? color ?? MyTheme.theme.buttonColor
              : MyTheme.theme.buttonColor.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
            side: BorderSide(
                color: MyTheme.theme.buttonColor, width: border ? 1.3 : 0),
          ),
          onPressed: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: child,
          ),
        ),
      );

  static wideButton(
          {@required Widget child,
          double labelSize,
          Color color,
          @required Function onTap,
          bool fill = true,
          bool border = true}) =>
      ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 50,
          maxHeight: 50,
          minWidth: 200,
          maxWidth: 300,
        ),
        child: Container(
          decoration: BoxDecoration(
            color:
                fill ? color ?? MyTheme.theme.buttonColor : Colors.transparent,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: FlatButton(
            onPressed: onTap,
            child: child,
          ),
        ),
      );

  static wideButtonIcon(
          {@required Widget child,
          double labelSize,
          Color color,
          @required Function onTap,
          @required Icon icon,
          bool fill = true,
          bool border = true}) =>
      ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 50,
          maxHeight: 50,
          minWidth: 200,
          maxWidth: 300,
        ),
        child: Container(
          decoration: BoxDecoration(
            color:
                fill ? color ?? MyTheme.theme.buttonColor : Colors.transparent,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: FlatButton.icon(
            icon: icon,
            onPressed: onTap,
            label: child,
          ),
        ),
      );
}
