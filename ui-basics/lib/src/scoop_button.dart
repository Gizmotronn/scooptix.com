import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'theme.dart';

enum ButtonFill { filled, outlined, none }
enum ScoopButtonTheme { primary, secondary, custom }

class ScoopButton extends StatefulWidget {
  final String? title;
  late final Color hoverColor;
  late final Color color;
  late final Color tapColor;
  final ButtonFill fill;

  /// Determines the [color], [hoverColor] and [tapColor]. Will override those fields if set to primary or secondary.
  final ScoopButtonTheme buttonTheme;
  final double? minHeight;
  final double? maxHeight;
  final double? minWidth;
  final double? maxWidth;
  final Function() onTap;
  final Widget? leading;
  final String? leadingSVGPath;
  final Color? leadingColor;
  final double? leadingSize;
  final Widget? trailing;
  final String? trailingSVGPath;
  final Color? trailingColor;
  final Color? hoverTrailingColor;
  final double? trailingSize;
  final TextStyle? textStyle;
  final AlignmentGeometry? textAlignment;
  final Color? hoverTextColor;

  /// If set to true the button will only show the leading icon and no title or trailing icon
  final bool leadingOnly;

  ScoopButton(
      {Key? key,
      this.title,
      this.fill = ButtonFill.filled,
      this.buttonTheme = ScoopButtonTheme.primary,
      this.minHeight,
      this.maxHeight,
      this.minWidth,
      this.maxWidth,
      required this.onTap,
      this.leading,
      this.leadingOnly = false,
      hoverColor = MyTheme.primaryOff,
      color = MyTheme.primaryMain,
      tapColor = MyTheme.primaryOff,
      this.textStyle,
      this.trailingSVGPath,
      this.trailingColor,
      this.trailingSize,
      this.trailing,
      this.leadingSVGPath,
      this.leadingColor,
      this.leadingSize,
      this.textAlignment,
      this.hoverTextColor = MyTheme.background,
      this.hoverTrailingColor = MyTheme.background})
      : super(key: key) {
    if (buttonTheme == ScoopButtonTheme.primary) {
      this.color = MyTheme.primaryMain;
      this.hoverColor = MyTheme.primaryOff;
      this.tapColor = MyTheme.primaryOff;
    } else if (buttonTheme == ScoopButtonTheme.secondary) {
      this.color = MyTheme.secondaryMain;
      this.hoverColor = MyTheme.secondaryOff;
      this.tapColor = MyTheme.secondaryOff;
    } else {
      this.color = color;
      this.hoverColor = hoverColor;
      this.tapColor = tapColor;
    }
  }

  @override
  _ScoopButtonState createState() => _ScoopButtonState();
}

class _ScoopButtonState extends State<ScoopButton> {
  bool isHover = false;
  bool isTap = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (d) {
        setState(() {
          isTap = false;
        });
      },
      onTapDown: (d) {
        setState(() {
          isTap = true;
        });
      },
      onTapCancel: () {
        setState(() {
          isTap = false;
        });
      },
      child: InkWell(
        onTap: widget.onTap,
        focusColor: widget.tapColor,
        splashColor: widget.tapColor,
        borderRadius: BorderRadius.circular(8),
        onHover: (v) => setState(() => isHover = v),
        child: Container(
          constraints: BoxConstraints(
            minHeight: widget.minHeight ?? 48,
            maxHeight: widget.maxHeight ?? 48,
            minWidth: widget.minWidth ?? 50,
            maxWidth: widget.maxWidth ?? 250,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: _borderColor(), width: 2),
            color: _buttonColor(),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.leading != null) widget.leading!.paddingRight(MyTheme.elementSpacing),
                if (widget.leading == null && widget.leadingSVGPath != null)
                  SvgPicture.asset(
                    widget.leadingSVGPath!,
                    height: widget.leadingSize ?? 16,
                    width: widget.leadingSize ?? 16,
                    color: isHover
                        ? widget.fill == ButtonFill.none
                            ? MyTheme.primaryMain
                            : widget.fill == ButtonFill.filled
                                ? MyTheme.background
                                : widget.leadingColor ?? MyTheme.background
                        : widget.leadingColor ?? MyTheme.background,
                  ).paddingRight(MyTheme.elementSpacing).paddingLeft(MyTheme.elementSpacing),
                if ((widget.leading == null && widget.leadingSVGPath == null) &&
                    !widget.leadingOnly &&
                    (widget.trailing != null || widget.trailingSVGPath != null))
                  const SizedBox(
                    width: MyTheme.elementSpacing,
                  ),
                if (!widget.leadingOnly)
                  widget.textAlignment == null
                      ? _buttonText()
                      : Expanded(
                          child: Align(alignment: widget.textAlignment!, child: _buttonText()),
                        ),
                if (widget.trailing != null) widget.trailing!,
                if (widget.trailing == null && widget.trailingSVGPath != null && !widget.leadingOnly)
                  SvgPicture.asset(
                    widget.trailingSVGPath!,
                    height: widget.trailingSize ?? 16,
                    width: widget.trailingSize ?? 16,
                    color: isHover ? widget.hoverTrailingColor : widget.trailingColor ?? MyTheme.background,
                  ).paddingLeft(MyTheme.elementSpacing).paddingRight(MyTheme.elementSpacing),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _buttonColor() {
    if (widget.fill == ButtonFill.filled) {
      if (isHover) {
        return isTap ? widget.tapColor : widget.hoverColor;
      } else {
        return widget.color;
      }
    } else if (widget.fill == ButtonFill.none) {
      return Colors.transparent;
    } else {
      if (isHover) {
        return isTap ? MyTheme.background : widget.hoverColor;
      } else {
        return Colors.transparent;
      }
    }
  }

  Color _borderColor() {
    if (widget.fill == ButtonFill.filled || widget.fill == ButtonFill.none) {
      return Colors.transparent;
    } else {
      return isTap
          ? widget.tapColor
          : isHover
              ? widget.hoverColor
              : widget.color;
    }
  }

  Widget _buttonText() {
    return AutoSizeText(
      widget.title ?? '',
      style: (widget.textStyle ?? MyTheme.button).copyWith(
        color: widget.fill == ButtonFill.filled
            ? isHover
                ? widget.hoverTextColor
                : MyTheme.background
            : widget.fill == ButtonFill.none
                ? isHover
                    ? MyTheme.primaryMain
                    : isTap
                        ? MyTheme.primaryMain
                        : widget.textStyle == null
                            ? MyTheme.white
                            : widget.textStyle!.color
                : isTap
                    ? widget.tapColor
                    : isHover
                        ? widget.hoverTextColor
                        : widget.textStyle != null
                            ? widget.textStyle!.color
                            : widget.color,
      ),
    );
  }
}

class OnTapAnimationButton extends StatefulWidget {
  final double? width;
  final double? height;
  final Color? color;
  final Function onTap;
  final bool fill;
  final bool border;
  final Color onTapColor;
  final Widget onTapContent;
  final Widget child;
  final Widget? suffixIcon;
  final Color? suffixBackgroundColor;

  const OnTapAnimationButton(
      {Key? key,
      this.width,
      this.height,
      this.color,
      required this.onTap,
      this.fill = true,
      this.border = true,
      required this.onTapColor,
      required this.onTapContent,
      required this.child,
      this.suffixIcon,
      this.suffixBackgroundColor})
      : super(key: key);

  @override
  _OnTapAnimationButtonState createState() => _OnTapAnimationButtonState();
}

class _OnTapAnimationButtonState extends State<OnTapAnimationButton> with SingleTickerProviderStateMixin {
  late AnimationController opacityController;
  double opacity = 0.0;

  @override
  void initState() {
    opacityController = AnimationController(
        vsync: this, lowerBound: 0.0, upperBound: 1.0, duration: const Duration(milliseconds: 1500));
    super.initState();
  }

  @override
  void dispose() {
    opacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, SizingInformation size) {
      return Container(
        constraints: BoxConstraints(
          minHeight: widget.height == null
              ? size.isDesktop
                  ? 40
                  : 35
              : widget.height!,
          maxHeight: widget.height == null
              ? size.isDesktop
                  ? 40
                  : 35
              : widget.height!,
          minWidth: widget.width ?? 130,
          maxWidth: widget.width ?? 200,
        ),
        child: Stack(
          children: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor:
                    widget.fill ? widget.color ?? MyTheme.secondaryMain : MyTheme.secondaryMain.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  side: BorderSide(color: widget.color ?? MyTheme.secondaryMain, width: widget.border ? 1.3 : 0),
                ),
              ),
              onPressed: () async {
                widget.onTap();
                setState(() {
                  opacity = 1.0;
                });
                await Future.delayed(const Duration(milliseconds: 4000));
                setState(() {
                  opacity = 0.0;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: widget.child,
              ),
            ),
            if (widget.suffixIcon != null)
              Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                width: widget.height == null
                    ? size.isDesktop
                        ? 40
                        : 35
                    : widget.height!,
                child: InkWell(
                  onTap: () async {
                    widget.onTap();
                    setState(() {
                      opacity = 1.0;
                    });
                    await Future.delayed(const Duration(milliseconds: 4000));
                    setState(() {
                      opacity = 0.0;
                    });
                  },
                  child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: ShapeDecoration(
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.only(topRight: Radius.circular(5), bottomRight: Radius.circular(5))),
                          color: widget.suffixBackgroundColor),
                      child: widget.suffixIcon!),
                ),
              ),
            Positioned(
              top: 0,
              height: widget.height == null
                  ? size.isDesktop
                      ? 40
                      : 35
                  : widget.height!,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: opacity,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    color: widget.onTapColor,
                    child: Center(child: widget.onTapContent),
                  ),
                ),
              ),
            )
          ],
        ),
      );
    });
  }
}
