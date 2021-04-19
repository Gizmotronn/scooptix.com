import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../../../UI/theme.dart';

class EventDetailTitle extends StatelessWidget {
  final String title;
  const EventDetailTitle(this.title, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      title,
      style: Theme.of(context).textTheme.headline3.copyWith(color: MyTheme.appolloGreen, fontWeight: FontWeight.w600),
    );
  }
}
