import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';

class ExpandImageCard extends StatelessWidget {
  final BorderRadius borderRadius;

  const ExpandImageCard({
    Key key,
    @required this.imageUrl, this.borderRadius,
  }) : super(key: key);

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return imageUrl == null
        ? Container()
        : Container(
            decoration: BoxDecoration(
                borderRadius:borderRadius?? BorderRadius.circular(8),
                image: DecorationImage(fit: BoxFit.cover, image: ExtendedImage.network(imageUrl).image)),
          );
  }
}
