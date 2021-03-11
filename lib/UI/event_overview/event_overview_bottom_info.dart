import 'package:flutter/material.dart';

import '../theme.dart';

class EventOverviewBottomInfos extends StatelessWidget {
  const EventOverviewBottomInfos({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      width: screenSize.width,
      height: screenSize.height * 0.3,
      color: MyTheme.appolloBlack,
    );
  }
}
