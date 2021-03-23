import 'package:flutter/material.dart';

import '../../theme.dart';

class WhiteCard extends StatelessWidget {
  final Widget child;

  const WhiteCard({Key key, @required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: MyTheme.appolloWhite,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: MyTheme.appolloGrey.withAlpha(20),
              spreadRadius: 5,
              blurRadius: 10,
            ),
          ],
        ),
        child: child ?? SizedBox());
  }
}
