import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../../theme.dart';

class CardButton extends StatefulWidget {
  final Function() onTap;

  final String title;
  final Color? activeColor;
  final Color? disabledColor;
  final Color? activeColorText;
  final Color? disabledColorText;
  final BorderRadius? borderRadius;

  final double? width;
  final double? height;

  const CardButton(
      {Key? key,
      required this.onTap,
      required this.title,
      this.borderRadius,
      this.activeColor,
      this.disabledColor,
      this.activeColorText,
      this.disabledColorText,
      this.width,
      this.height})
      : super(key: key);

  @override
  _CardButtonState createState() => _CardButtonState();
}

class _CardButtonState extends State<CardButton> {
  bool isHover = false;
  @override
  Widget build(BuildContext context) {
    final activeColor = widget.activeColor ?? MyTheme.appolloGreen.withOpacity(.9);
    final disabledColor = widget.disabledColor ?? MyTheme.appolloGreen;
    final activeColorText = widget.activeColorText ?? MyTheme.appolloWhite;
    final disabledColorText = widget.disabledColorText ?? MyTheme.appolloBackgroundColor;

    return InkWell(
      onTap: widget.onTap,
      onHover: (v) {
        setState(() => isHover = v);
      },
      child: Container(
        height: widget.height ?? 34,
        width: widget.width,
        decoration: BoxDecoration(
          color: isHover ? activeColor : disabledColor,
          borderRadius: widget.borderRadius ??
              BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
        ),
        child: Center(
            child: AutoSizeText(
          widget.title,
          style: MyTheme.textTheme.button!.copyWith(color: isHover ? activeColorText : disabledColorText),
        )),
      ),
    );
  }
}

class ColorCard extends StatelessWidget {
  final String? title;
  final Color color;
  final Color textColor;

  const ColorCard({Key? key, required this.color, this.title, required this.textColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: color,
      ),
      child: Center(
          child: AutoSizeText(
        title ?? '',
        style: Theme.of(context).textTheme.button!.copyWith(color: textColor),
      )).paddingHorizontal(8).paddingVertical(4),
    );
  }
}
