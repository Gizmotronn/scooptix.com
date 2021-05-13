import 'package:auto_size_text/auto_size_text.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import '../../../model/event.dart';
import '../../../UI/theme.dart';

class EventGallary extends StatelessWidget {
  const EventGallary({
    Key key,
    this.event,
  }) : super(key: key);
  final Event event;

  @override
  Widget build(BuildContext context) {
    if (event.images.length == 0) {
      return SizedBox.shrink();
    }
    return Container(
      child: Column(
        children: [
          AutoSizeText(
            'Event Gallery',
            style: MyTheme.lightTextTheme.headline2.copyWith(color: MyTheme.appolloGreen, fontWeight: FontWeight.w600),
          ).paddingBottom(MyTheme.elementSpacing),
          GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: event.images.length,
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: MyTheme.elementSpacing,
                crossAxisSpacing: MyTheme.elementSpacing,
              ),
              itemBuilder: (ctx, index) => Container(
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                      child: ExtendedImage.network(event.images[index] ?? "", cache: true, fit: BoxFit.cover,
                          loadStateChanged: (ExtendedImageState state) {
                        switch (state.extendedImageLoadState) {
                          case LoadState.loading:
                            return Container(
                              color: Colors.white,
                            );
                          case LoadState.completed:
                            return state.completedWidget;
                          default:
                            return Container(
                              color: Colors.white,
                            );
                        }
                      }),
                    ),
                  )).paddingBottom(MyTheme.elementSpacing),
        ],
      ),
    );
  }
}
