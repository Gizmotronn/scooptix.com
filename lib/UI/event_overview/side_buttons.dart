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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 35,
              width: 3,
              decoration: BoxDecoration(
                color: isTap ? MyTheme.appolloPurple : MyTheme.appolloGrey,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            SizedBox(width: 10),
            AutoSizeText(
              title ?? '',
              style: Theme.of(context).textTheme.button.copyWith(
                  color: isTap ? MyTheme.appolloPurple : MyTheme.appolloGrey),
            ),
          ],
        ),
        decoration: BoxDecoration(
          color: MyTheme.appolloWhite,
          boxShadow: [
            BoxShadow(
              color: isTap ? MyTheme.appolloDimGrey : Colors.transparent,
              spreadRadius: 3.0,
              blurRadius: 5.0,
            )
          ],
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
