import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:ticketapp/UI/theme.dart';

class AppolloButton {
  static smallRaisedButton({@required Widget child, @required Function onTap, Color color = Colors.white}) => Container(
      constraints: BoxConstraints(
        minHeight: 40,
        maxHeight: 40,
        minWidth: 130,
        maxWidth: 200,
      ),
      child: RaisedButton(
        elevation: 3,
        color: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        onPressed: onTap,
        child: child,
      ));

  static smallButton(
          {@required Widget child,
          double width,
          double height,
          Color color,
          @required Function onTap,
          bool fill = true,
          bool border = true}) =>
      ResponsiveBuilder(builder: (context, SizingInformation size) {
        return Container(
          constraints: BoxConstraints(
            minHeight: height ?? size.isDesktop ? 40 : 25,
            maxHeight: height ?? size.isDesktop ? 40 : 25,
            minWidth: width ?? 130,
            maxWidth: width ?? 200,
          ),
          child: FlatButton(
            color: fill ? color ?? MyTheme.theme.buttonColor : MyTheme.theme.buttonColor.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
              side: BorderSide(color: color ?? MyTheme.theme.buttonColor, width: border ? 1.3 : 0),
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
          color: fill ? color ?? MyTheme.theme.buttonColor : MyTheme.theme.buttonColor.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
            side: BorderSide(color: MyTheme.theme.buttonColor, width: border ? 1.3 : 0),
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
          double heightMax,
          double heightMin,
          @required Function onTap,
          bool fill = true,
          bool border = true}) =>
      ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: heightMin ?? 50,
          maxHeight: heightMax ?? 50,
          minWidth: 200,
          maxWidth: 300,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: fill ? color ?? MyTheme.theme.buttonColor : Colors.transparent,
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
            color: fill ? color ?? MyTheme.theme.buttonColor : Colors.transparent,
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

class HoverAppolloButton extends StatefulWidget {
  final String title;
  final Color hoverColor;
  final Color color;
  final bool fill;
  final double minHeight;
  final double maxHeight;
  final double minWidth;
  final double maxWidth;

  const HoverAppolloButton(
      {Key key,
      this.title,
      @required this.hoverColor,
      this.color,
      this.fill = false,
      this.minHeight,
      this.maxHeight,
      this.minWidth,
      this.maxWidth})
      : super(key: key);

  @override
  _HoverAppolloButtonState createState() => _HoverAppolloButtonState();
}

class _HoverAppolloButtonState extends State<HoverAppolloButton> {
  bool isHover = false;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      onHover: (v) => setState(() => isHover = v),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: widget.minHeight ?? 45,
          maxHeight: widget.maxHeight ?? 45,
          minWidth: widget.minWidth ?? 150,
          maxWidth: widget.maxWidth ?? 250,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(color: isHover ? Colors.transparent : widget.color),
            color: widget.fill
                ? widget.color
                : isHover
                    ? widget.hoverColor
                    : Colors.transparent,
          ),
          child: Center(
            child: AutoSizeText(
              widget.title ?? '',
              style: Theme.of(context).textTheme.button.copyWith(
                    color: isHover ? MyTheme.appolloWhite : widget.color,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
