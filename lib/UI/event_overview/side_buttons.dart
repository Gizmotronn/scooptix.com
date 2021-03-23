import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:ticketapp/UI/theme.dart';

class SideButton extends StatelessWidget {
  final String title;
  final bool isTap;
  final Function onTap;

  const SideButton({
    Key key,
    this.title,
    this.isTap,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 115,
        height: 35,
        child: Center(
          child: AutoSizeText(
            title ?? '',
            style: Theme.of(context).textTheme.button.copyWith(
                color: isTap ? MyTheme.appolloGreen : MyTheme.appolloGrey),
          ),
        ),
      ),
    );
  }
}
