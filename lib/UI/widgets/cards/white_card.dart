import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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

class WhiteCardWithNoElevation extends StatefulWidget {
  final Widget child;
  final Function(double pixel) boxHeight;

  const WhiteCardWithNoElevation({Key key, this.child, this.boxHeight}) : super(key: key);

  @override
  _WhiteCardWithNoElevationState createState() => _WhiteCardWithNoElevationState();
}

class _WhiteCardWithNoElevationState extends State<WhiteCardWithNoElevation> {
  GlobalKey widgetKey = GlobalKey();

  double height = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.boxHeight != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        final box = widgetKey.currentContext.findRenderObject() as RenderBox;
        height = box.size.height;
        widget.boxHeight(height);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: widgetKey,
      decoration: BoxDecoration(
        color: MyTheme.appolloWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: widget.child,
    );
  }
}
