import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:ticketapp/UI/widgets/icons/svgicon.dart';
import 'package:ticketapp/utilities/svg/icon.dart';

import '../../theme.dart';

class CustomDropdown extends StatefulWidget {
  final Widget child;
  final String title;
  final double width;

  CustomDropdown({Key key, this.child, this.title, this.width = 20}) : super(key: key);

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  bool _isExpanded = false;
  bool _isHover = false;
  OverlayEntry _overlayEntry;

  Size widgetSize = Size(0, 0);
  Offset widgetOffset = Offset(0, 0);

  GlobalKey actionKey;

  @override
  void initState() {
    actionKey = LabeledGlobalKey(widget.title);
    super.initState();
  }

  OverlayEntry _createDrop() {
    return OverlayEntry(builder: (context) {
      return Stack(
        children: [
          GestureDetector(
            onTap: () {
              _overlayEntry.remove();
              setState(() {
                _isExpanded = false;
              });
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width,
              color: Colors.transparent,
            ),
          ),
          Positioned(
            left: widgetOffset.dx,
            width: widgetSize.width + widget.width,
            top: widgetOffset.dy,
            child: AppolloDropdown(
              title: widget.title,
              isExpanded: _isExpanded,
              isHover: _isHover,
              child: widget.child,
              onTap: () {
                setState(() {
                  if (_isExpanded) {
                    _overlayEntry.remove();
                  } else {
                    _getWidgetInfo();
                    _overlayEntry = _createDrop();
                    Overlay.of(context).insert(_overlayEntry);
                  }
                  _isExpanded = !_isExpanded;
                });
              },
            ),
          ),
        ],
      );
    });
  }

  void _getWidgetInfo() {
    RenderBox renderBox = actionKey.currentContext.findRenderObject() as RenderBox;
    widgetSize = Size(renderBox.size.width, renderBox.size.height);
    final offset = renderBox.localToGlobal(Offset.zero);
    widgetOffset = Offset(offset.dx, offset.dy);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: actionKey,
      onHover: (v) {
        setState(() {
          _isHover = v;
        });
      },
      onTap: () {
        setState(() {
          if (_isExpanded) {
            _overlayEntry.remove();
          } else {
            _getWidgetInfo();
            _overlayEntry = _createDrop();
            Overlay.of(context).insert(_overlayEntry);
          }
          _isExpanded = !_isExpanded;
        });
      },
      child: Container(
          decoration: BoxDecoration(
            color: _isExpanded ? MyTheme.appolloBackgroundColor2 : null,
            border: Border.all(color: _isHover ? MyTheme.appolloGreen : Colors.transparent, width: 0.8),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AutoSizeText(
                '${widget.title}',
                style: Theme.of(context).textTheme.button.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: _isExpanded || _isHover ? MyTheme.appolloGreen : MyTheme.appolloWhite),
              ),
              const SizedBox(width: 10),
              Container(
                height: 20,
                child: SvgIcon(_isExpanded ? AppolloSvgIcon.arrowup : AppolloSvgIcon.arrowdown,
                    color: MyTheme.appolloWhite),
              ),
            ],
          ).paddingAll(4)),
    );
  }
}

class AppolloDropdown extends StatefulWidget {
  final String title;
  final Widget child;
  final bool isExpanded;
  final bool isHover;

  final Function onTap;

  const AppolloDropdown({
    Key key,
    @required this.title,
    @required this.child,
    @required this.isExpanded,
    @required this.isHover,
    this.onTap,
  }) : super(key: key);

  @override
  _AppolloDropdownState createState() => _AppolloDropdownState();
}

class _AppolloDropdownState extends State<AppolloDropdown> {
  bool _isHover = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onHover: (v) {
        setState(() {
          _isHover = v;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: widget.isExpanded ? MyTheme.appolloBackgroundColor2 : null,
          border: Border.all(color: _isHover ? MyTheme.appolloGreen : Colors.transparent, width: 0.8),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: widget.onTap,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AutoSizeText(
                    '${widget.title}',
                    style: Theme.of(context).textTheme.button.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: widget.isExpanded || widget.isHover ? MyTheme.appolloGreen : MyTheme.appolloWhite),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    height: 20,
                    child: SvgIcon(widget.isExpanded ? AppolloSvgIcon.arrowup : AppolloSvgIcon.arrowdown,
                        color: MyTheme.appolloWhite),
                  ),
                ],
              ).paddingBottom(8),
            ),
            Container(
              alignment: Alignment.topCenter,
              key: ValueKey(widget.isExpanded),
              height: widget.isExpanded ? null : 0,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      child: Builder(
                        builder: (context) {
                          return widget.child;
                        },
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ).paddingHorizontal(8).paddingTop(8),
      ),
    );
  }
}
