import 'package:auto_size_text/auto_size_text.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

import '../../../UI/theme.dart';

class EventDetailNavbar extends StatelessWidget {
  const EventDetailNavbar({
    Key? key,
    this.imageURL,
    required this.mainText,
    required this.buttonText,
    required this.scrollController,
    required this.offset,
  }) : super(key: key);

  final String? imageURL;
  final String mainText;
  final String buttonText;
  final ScrollController scrollController;
  final double offset;
  final double bottomBarHeight = 64.0;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ClipRRect(
        borderRadius: BorderRadius.only(topRight: Radius.circular(8), topLeft: Radius.circular(8)),
        child: SizedBox(
          width: MyTheme.maxWidth,
          height: bottomBarHeight,
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      height: bottomBarHeight,
                      child: AspectRatio(
                        aspectRatio: 1.9,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            image: DecorationImage(
                              image: ExtendedImage.network(
                                imageURL ?? '',
                                cache: true,
                              ).image,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ).paddingRight(16),
                      ),
                    ),
                    AutoSizeText(
                      mainText,
                      maxLines: 1,
                      style:
                          MyTheme.textTheme.headline2!.copyWith(color: MyTheme.scoopGreen, fontWeight: FontWeight.w600),
                    ),
                  ],
                ).paddingLeft(8).paddingVertical(8),
                InkWell(
                  onTap: () {
                    scrollController.animateTo(offset, duration: MyTheme.animationDuration, curve: Curves.easeOut);
                  },
                  child: Container(
                    height: bottomBarHeight,
                    constraints: BoxConstraints(minWidth: 150),
                    decoration: BoxDecoration(
                        color: MyTheme.scoopYellow, borderRadius: BorderRadius.only(topRight: Radius.circular(5))),
                    child: Center(
                      child: Text(buttonText,
                              style: MyTheme.textTheme.button!.copyWith(
                                  fontWeight: FontWeight.w500, fontSize: 18, color: MyTheme.scoopBackgroundColor))
                          .paddingHorizontal(16),
                    ),
                  ),
                ),
              ],
            ),
          ).appolloCard(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            color: MyTheme.scoopCardColor,
          ),
        ),
      ),
    );
  }
}
