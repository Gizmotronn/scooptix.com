import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class EventDetailBackground extends StatelessWidget {
  final String coverImageURL;
  const EventDetailBackground({
    Key key,
    this.coverImageURL,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Positioned(
      width: screenSize.width * 1.01,
      height: screenSize.height * 1.01,
      child: Container(
        width: screenSize.width,
        height: screenSize.height,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: ExtendedImage.network(
                coverImageURL,
                cache: true,
              ).image,
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.grey, BlendMode.darken)),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 60.0, sigmaY: 60.0),
          child: Container(
            width: screenSize.width,
            height: screenSize.height,
            decoration: BoxDecoration(color: Colors.grey[900].withOpacity(0.2)),
          ),
        ),
      ),
    );
  }
}
