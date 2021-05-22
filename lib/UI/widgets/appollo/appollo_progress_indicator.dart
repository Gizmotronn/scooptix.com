import 'package:flutter/material.dart';

import '../../theme.dart';

class AppolloProgressIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(MyTheme.appolloGreen),
    );
  }
}

class AppolloButtonProgressIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(MyTheme.appolloWhite),
    );
  }
}
