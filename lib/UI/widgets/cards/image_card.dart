import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:ticketapp/UI/theme.dart';

class ExpandImageCard extends StatelessWidget {
  const ExpandImageCard({
    Key key,
    @required this.imageUrl,
  }) : super(key: key);

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return imageUrl == null
        ? Container()
        : Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(fit: BoxFit.cover, image: ExtendedImage.network(imageUrl).image)),
          ).paddingAll(4);
  }
}
