import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../theme.dart';

class AppolloButton {
  static regularButton(
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
            minHeight: height ?? size.isDesktop ? 40 : 35,
            maxHeight: height ?? size.isDesktop ? 40 : 35,
            minWidth: width ?? 130,
          ),
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: fill ? color ?? MyTheme.appolloGreen : MyTheme.appolloGreen.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
                side: BorderSide(color: color ?? MyTheme.appolloGreen, width: border ? 1.3 : 0),
              ),
            ),
            onPressed: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: child,
            ),
          ),
        );
      });
}

class OnTapAnimationButton extends StatefulWidget {
  final double width;
  final double height;
  final Color color;
  final Function onTap;
  final bool fill;
  final bool border;
  final Color onTapColor;
  final Widget onTapContent;
  final Widget child;

  OnTapAnimationButton(
      {this.width,
      this.height,
      this.color,
      @required this.onTap,
      this.fill = true,
      this.border = true,
      this.onTapColor,
      this.onTapContent,
      this.child});

  @override
  _OnTapAnimationButtonState createState() => _OnTapAnimationButtonState();
}

class _OnTapAnimationButtonState extends State<OnTapAnimationButton> with SingleTickerProviderStateMixin {
  AnimationController opacityController;
  double opacity = 0.0;

  @override
  void initState() {
    opacityController =
        AnimationController(vsync: this, lowerBound: 0.0, upperBound: 1.0, duration: Duration(milliseconds: 1500));
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
          minHeight: widget.height ?? size.isDesktop ? 40 : 35,
          maxHeight: widget.height ?? size.isDesktop ? 40 : 35,
          minWidth: widget.width ?? 130,
          maxWidth: widget.width ?? 200,
        ),
        child: Stack(
          children: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor:
                    widget.fill ? widget.color ?? MyTheme.appolloGreen : MyTheme.appolloGreen.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  side: BorderSide(color: widget.color ?? MyTheme.appolloGreen, width: widget.border ? 1.3 : 0),
                ),
              ),
              onPressed: () async {
                widget.onTap();
                setState(() {
                  opacity = 1.0;
                });
                await Future.delayed(Duration(milliseconds: 4000));
                setState(() {
                  opacity = 0.0;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: widget.child,
              ),
            ),
            Positioned(
              top: 0,
              height: widget.height ?? size.isDesktop ? 40 : 35,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: opacity,
                  duration: Duration(milliseconds: 300),
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
