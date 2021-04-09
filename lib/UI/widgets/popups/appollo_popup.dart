import 'package:flutter/material.dart';

import '../../theme.dart';

class AppolloPopup extends StatelessWidget {
  final List<PopupMenuEntry<String>> item;
  final Function(dynamic) onSelected;
  final String initialValue;

  final Widget child;

  const AppolloPopup({Key key, this.item, this.onSelected, this.initialValue = '', this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      child: child,
      // offset: Offset(0, 0),
      initialValue: initialValue,
      onSelected: onSelected,
      color: Theme.of(context).canvasColor.withOpacity(.7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: MyTheme.appolloWhite.withOpacity(.4),
          width: 0.5,
        ),
      ),
      itemBuilder: (_) => item,
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
