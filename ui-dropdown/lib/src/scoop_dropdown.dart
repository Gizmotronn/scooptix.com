import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:equatable/equatable.dart';

import 'theme.dart';

class ScoopDropdown extends StatefulWidget {
  final String title;
  final double width;
  final Function(String, int) onChange;
  final List<Menu> item;
  final String? leadingSvg;
  final bool isSelected;

  /// Set this if you have nested viewports, which causes overlays to be displayed at the wrong position
  final Offset overlayOffset;

  const ScoopDropdown(
      {Key? key,
      required this.title,
      this.width = 20,
      required this.item,
      required this.onChange,
      this.leadingSvg,
      this.isSelected = false,
      this.overlayOffset = Offset.zero})
      : super(key: key);

  @override
  _ScoopDropdownState createState() => _ScoopDropdownState();
}

class _ScoopDropdownState extends State<ScoopDropdown> {
  bool _isExpanded = false;
  bool _isHover = false;
  late OverlayEntry _overlayEntry;
  late GlobalKey actionKey;

  late Size widgetSize;
  late Offset widgetOffset;

  @override
  void initState() {
    actionKey = LabeledGlobalKey(widget.title);
    super.initState();
  }

  OverlayEntry _createDrop() {
    return OverlayEntry(builder: (context) {
      return Material(
        color: Colors.transparent,
        child: Listener(
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
                top: widgetOffset.dy + 50,
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
                        Overlay.of(context)!.insert(_overlayEntry);
                      }
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _getWidgetInfo() {
    RenderBox renderBox = actionKey.currentContext!.findRenderObject() as RenderBox;
    widgetSize = Size(renderBox.size.width, renderBox.size.height);
    final offset = renderBox.localToGlobal(widget.overlayOffset);
    widgetOffset = Offset(offset.dx, offset.dy);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      hoverColor: Colors.transparent,
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
            Overlay.of(context)!.insert(_overlayEntry);
          }
          _isExpanded = !_isExpanded;
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          widget.leadingSvg != null
              ? SvgPicture.asset(
                  widget.leadingSvg!,
                  height: 22,
                  width: 20,
                  color: _isExpanded || _isHover || widget.isSelected ? MyTheme.primaryMain : MyTheme.unselectedGrey,
                )
              : const SizedBox.shrink(),
          Container(
              child: AutoSizeText(
            widget.title,
            style: MyTheme.dropdownTitle.copyWith(
                color: _isExpanded || _isHover || widget.isSelected ? MyTheme.primaryMain : MyTheme.unselectedGrey),
          ).paddingAll(MyTheme.elementSpacing)),
          SizedBox(
            height: 20,
            child: SvgPicture.asset("packages/ui_dropdown/assets/arrow_down.svg",
                color: _isExpanded || _isHover || widget.isSelected ? MyTheme.primaryMain : MyTheme.unselectedGrey),
          ),
        ],
      ),
    );
  }
}

class AppolloDropdownContent extends StatefulWidget {
  final String title;
  final bool isExpanded;
  final Function() onTap;
  final List<Menu> items;
  final Function(String, int) onChange;

  const AppolloDropdownContent({
    Key? key,
    required this.title,
    required this.isExpanded,
    required this.onTap,
    required this.items,
    required this.onChange,
  }) : super(key: key);

  @override
  _AppolloDropdownContentState createState() => _AppolloDropdownContentState();
}

class _AppolloDropdownContentState extends State<AppolloDropdownContent> {
  int hoverIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: widget.isExpanded ? MyTheme.cardColor : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white, width: 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: widget.onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.topCenter,
                  key: ValueKey(widget.isExpanded),
                  height: widget.isExpanded ? null : 0,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          widget.items.length,
                          (index) => InkWell(
                            onTap: () {
                              widget.onChange(widget.items[index].title, index);
                              widget.onTap();
                            },
                            onHover: (value) {
                              if (value) {
                                setState(() {
                                  hoverIndex = index;
                                });
                              } else {
                                setState(() {
                                  hoverIndex = -1;
                                });
                              }
                            },
                            child: _hoverText(
                              context,
                              title: widget.items[index].title,
                              comingSoon: widget.items[index].comingSoon,
                              isHover: index == hoverIndex,
                            ).paddingBottom(index != widget.items.length - 1 ? MyTheme.elementSpacing : 0),
                          ),
                        )),
                  ),
                ),
              ],
            ),
          ),
        ],
      ).paddingAll(MyTheme.elementSpacing),
    );
  }

  Widget _hoverText(BuildContext context, {required String title, required bool isHover, required bool comingSoon}) {
    return Text(
      title,
      style: MyTheme.dropdownTitle.copyWith(
          color: comingSoon ? MyTheme.unselectedGrey : MyTheme.white,
          fontWeight: !comingSoon && isHover ? FontWeight.w600 : FontWeight.w400),
    );
  }
}

class Menu extends Equatable {
  final int? id;
  final String title;
  final String? subtitle;
  final String? fullDate;
  final String? svgIcon;
  final bool comingSoon;

  const Menu(this.title, {this.id, this.subtitle, this.fullDate, this.svgIcon, this.comingSoon = false});

  @override
  List<Object> get props => [];
}
