import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgIcon extends StatelessWidget {
  const SvgIcon(this.svg, {Key key, this.color, this.size}) : super(key: key);

  final String svg;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: size ?? 16,
        width: size ?? 16,
        child: SvgPicture.asset(svg, color: color, height: size ?? 16, width: size ?? 16));
  }
}
