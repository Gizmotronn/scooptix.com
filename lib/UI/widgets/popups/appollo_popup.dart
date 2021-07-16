import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ticketapp/UI/event_overview/event_overview_home.dart';
import 'package:ticketapp/UI/widgets/icons/svgicon.dart';
import 'package:ticketapp/utilities/svg/icon.dart';

import '../../theme.dart';

typedef OnChange = Function(String title, int index);

class AppolloDropdown extends StatefulWidget {
  final String title;
  final double width;
  final OnChange onChange;
  final List<Menu> item;

  AppolloDropdown({Key key, this.title, this.width = 3.5, @required this.item, this.onChange}) : super(key: key);

  @override
  _AppolloDropdownState createState() => _AppolloDropdownState();
}

class _AppolloDropdownState extends State<AppolloDropdown> {
  bool _isExpanded = false;
  bool _isHover = false;
  OverlayEntry _overlayEntry;
  GlobalKey actionKey;

  Size widgetSize;
  Offset widgetOffset;

  @override
  void initState() {
    actionKey = LabeledGlobalKey(widget.title);
    super.initState();
  }

  OverlayEntry _createDrop() {
    return OverlayEntry(builder: (context) {
      return Listener(
        onPointerSignal: (signal) {
          if (signal is PointerScrollEvent) {
            _overlayEntry.remove();
            setState(() {
              _isExpanded = false;
            });
          }
        },
        child: Stack(
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
              top: widgetOffset.dy - 1,
              child: AppolloDropdownContent(
                title: widget.title,
                onChange: widget.onChange,
                isExpanded: _isExpanded,
                items: widget.item,
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
        ),
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
            color: _isExpanded ? MyTheme.appolloBackgroundColorLight : null,
            border: Border.all(color: _isHover ? MyTheme.appolloGreen : Colors.transparent, width: 0.8),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AutoSizeText(
                '${widget.title}',
                style: MyTheme.textTheme.bodyText1.copyWith(
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
          ).paddingAll(13)),
    );
  }
}

class AppolloDropdownContent extends StatefulWidget {
  final String title;
  final bool isExpanded;
  final Function onTap;
  final List<Menu> items;
  final OnChange onChange;

  const AppolloDropdownContent({
    Key key,
    @required this.title,
    @required this.isExpanded,
    this.onTap,
    this.items,
    @required this.onChange,
  }) : super(key: key);

  @override
  _AppolloDropdownContentState createState() => _AppolloDropdownContentState();
}

class _AppolloDropdownContentState extends State<AppolloDropdownContent> {
  bool _isHover = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onHover: (v) => setState(() => _isHover = v),
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: widget.isExpanded ? MyTheme.appolloBackgroundColor : null,
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
                    style: MyTheme.textTheme.bodyText1.copyWith(
                        fontWeight: FontWeight.w400,
                        color: widget.isExpanded || _isHover ? MyTheme.appolloGreen : MyTheme.appolloWhite),
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
              child: Align(
                alignment: Alignment.topLeft,
                child: Container(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                        widget.items.length,
                        (index) => InkWell(
                          onTap: () {},
                          onTapDown: (v) {
                            if (widget.onChange != null) {
                              widget.onChange(widget.items[index].title, index);
                            }
                          },
                          onHover: (value) {
                            for (var i = 0; i < widget.items.length; i++) {
                              setState(() {
                                widget.items[i].isTap = false;
                              });
                            }
                            setState(() {
                              widget.items[index].isTap = value;
                            });
                          },
                          child: _hoverText(
                            context,
                            title: widget.items[index].title,
                            isHover: widget.items[index].isTap,
                          ).paddingBottom(8),
                        ),
                      )),
                ),
              ),
            )
          ],
        ).paddingAll(13),
      ),
    );
  }

  Widget _hoverText(BuildContext context, {String title, bool isHover}) {
    return Text(
      title,
      style: MyTheme.textTheme.bodyText1.copyWith(fontWeight: isHover ? FontWeight.w600 : FontWeight.w400),
    );
  }
}
