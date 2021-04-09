import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../../../UI/theme.dart';

class AppolloCounter extends StatelessWidget {
  final String counterType;

  const AppolloCounter({Key key, @required this.counterType}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AutoSizeText('00', style: Theme.of(context).textTheme.headline1.copyWith(fontWeight: FontWeight.w600))
              .paddingTop(16)
              .paddingBottom(32),
          AutoSizeText(counterType, style: Theme.of(context).textTheme.button).paddingBottom(8),
        ],
      ).paddingHorizontal(32),
    ).appolloCard();
  }
}
