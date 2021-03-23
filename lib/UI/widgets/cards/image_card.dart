
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
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
              fit: BoxFit.cover,
              image: ExtendedImage.network(imageUrl ??
                      'https://media.istockphoto.com/vectors/abstract-pop-art-line-and-dots-color-pattern-background-vector-liquid-vector-id1017781486?k=6&m=1017781486&s=612x612&w=0&h=nz4YljNqJ0xjxcdVVJge3dW3cqNakWjG7u2oFqW4tjs=')
                  .image)),
    ).paddingAll(4);
  }
}