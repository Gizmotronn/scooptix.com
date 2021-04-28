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
  Offset offset = Offset(0.0, 0.0);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = context.findRenderObject() as RenderBox;
      Offset newOffset = box.localToGlobal(Offset.zero);
      if (newOffset != offset) {
        offset = newOffset;
        widget.boxOffset(offset);
      }
    });
    return Container(
      child: widget.child,
    );
  }
}
