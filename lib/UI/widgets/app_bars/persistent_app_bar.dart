import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class AppolloPersistentAppBar extends SliverPersistentHeaderDelegate {
  final double appbarHeight;
  final double offset;
  final FloatingHeaderSnapConfiguration snap;

  final Widget shrinkChild;
  final Widget child;

  AppolloPersistentAppBar({
    @required this.shrinkChild,
    @required this.child,
    @required this.appbarHeight,
    this.offset,
    this.snap,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final firstBarOffset = (-shrinkOffset * 0.01) - shrinkOffset;
    final secondBarOffset = (-shrinkOffset * 0.01) - shrinkOffset;
    return Container(
      color: Colors.white,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            bottom: secondBarOffset < -1.00 ? 1 : secondBarOffset,
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Wrap(
                children: [child ?? Container()],
              ),
            ),
          ),
          Positioned(
            top: firstBarOffset,
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Wrap(
                children: [shrinkChild ?? Container()],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => appbarHeight;

  @override
  double get minExtent => 60;

  @override
  FloatingHeaderSnapConfiguration get snapConfiguration => snap;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
