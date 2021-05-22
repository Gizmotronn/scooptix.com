import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../../theme.dart';

class NavbarButton extends StatelessWidget {
  final String title;
  final Function onTap;
  final bool isTap;

  const NavbarButton({Key key, @required this.title, @required this.onTap, @required this.isTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AutoSizeText(title ?? '',
                    style: MyTheme.textTheme.bodyText1
                        .copyWith(color: isTap ? MyTheme.appolloGreen : MyTheme.appolloWhite))
                .paddingBottom(4),
            Container(
              height: 1.5,
              width: 20,
              color: isTap ? MyTheme.appolloGreen : Colors.transparent,
            )
          ],
        ),
      ),
    );
  }
}
