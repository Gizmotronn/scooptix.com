import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../theme.dart';

class CardButton extends StatefulWidget {
  final Function onTap;

  final String title;
  const CardButton({
    Key key,
    @required this.onTap,
    @required this.title,
  }) : super(key: key);

  @override
  _CardButtonState createState() => _CardButtonState();
}

class _CardButtonState extends State<CardButton> {
  bool isHover = false;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      onHover: (v) {
        setState(() => isHover = v);
      },
      child: Container(
        height: 40,
        width: 175,
        decoration: BoxDecoration(
          color: isHover
              ? MyTheme.appolloPurple
              : MyTheme.appolloPurple.withAlpha(40),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
        ),
        child: Center(
            child: AutoSizeText(
          widget.title ?? '',
          style: Theme.of(context).textTheme.button.copyWith(
              color: isHover ? MyTheme.appolloWhite : MyTheme.appolloPurple),
        )),
      ),
    );
  }
}
