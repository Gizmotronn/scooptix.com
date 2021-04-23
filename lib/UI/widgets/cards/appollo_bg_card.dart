import 'package:flutter/material.dart';

import '../../theme.dart';

class AppolloCard extends StatelessWidget {
  final Widget child;
  final Color color;

  const AppolloCard({Key key, @required this.child, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: color ?? MyTheme.appolloWhite,
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

class AppolloBackgroundCard extends StatelessWidget {
  final Widget child;

  const AppolloBackgroundCard({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MyTheme.appolloBackgroundColor2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

class BoxOffset extends StatefulWidget {
  final Widget child;
  final Function(Offset offset) boxOffset;

  const BoxOffset({Key key, this.child, this.boxOffset}) : super(key: key);

  @override
  _BoxOffsetState createState() => _BoxOffsetState();
}

class _BoxOffsetState extends State<BoxOffset> {
  GlobalKey widgetKey = GlobalKey();

  Size size = Size(0, 0);
  Offset offset = Offset(0.0, 0.0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = widgetKey.currentContext.findRenderObject() as RenderBox;
      offset = box.localToGlobal(Offset.zero);
      size = box.size;
      widget.boxOffset(offset);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: widgetKey,
      child: widget.child,
    );
  }
}
