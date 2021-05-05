import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:ticketapp/UI/widgets/icons/svgicon.dart';
import 'package:ticketapp/utilities/svg/icon.dart';

import '../../theme.dart';

class AppolloPopup extends StatefulWidget {
  final List<PopupMenuEntry<String>> item;
  final Function(dynamic) onSelected;
  final String initialValue;
  final Widget child;
  final bool isHover;

  const AppolloPopup({Key key, this.item, this.onSelected, this.initialValue = '', this.child, this.isHover = false})
      : super(key: key);
  @override
  _AppolloPopupState createState() => _AppolloPopupState();
}

class _AppolloPopupState extends State<AppolloPopup> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      child: widget.child,
      initialValue: widget.initialValue,
      onSelected: widget.onSelected,
      elevation: 0,
      offset: Offset(0.5, 0.0),
      color: MyTheme.appolloBackgroundColor2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: MyTheme.appolloGreen,
          width: 0.8,
        ),
      ),
      itemBuilder: (_) => widget.item,
    );
  }
}

class PopupButton extends StatelessWidget {
  final Widget title;
  final Widget icon;

  const PopupButton({
    Key key,
    @required this.title,
    @required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [title.paddingRight(4), icon],
    );
  }
}

class CustomDropdown extends StatefulWidget {
  final Widget child;

  final String title;

  CustomDropdown({Key key, this.child, this.title}) : super(key: key);

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  bool _isExpanded = false;
  bool _isHover = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        InkWell(
          onHover: (v) {
            setState(() {
              _isHover = v;
            });
          },
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: _isExpanded ? MyTheme.appolloBackgroundColor2 : null,
              border: Border.all(color: _isHover ? MyTheme.appolloGreen : Colors.transparent, width: 0.8),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                ).paddingBottom(8),
                _isExpanded
                    ? Container(
                        alignment: Alignment.topCenter,
                        key: ValueKey(_isExpanded),
                        height: _isExpanded ? null : 0,
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.start,
                          children: [
                            Container(
                              child: Builder(
                                builder: (context) {
                                  return widget.child;
                                },
                              ),
                            )
                          ],
                        ),
                      )
                    : SizedBox(),
              ],
            ).paddingHorizontal(8).paddingTop(8),
          ),
        ),
      ],
    );
  }
}
