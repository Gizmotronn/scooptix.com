import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import '../../../model/event.dart';
import 'event_title.dart';
import '../../../UI/theme.dart';

class EventGallary extends StatelessWidget {
  const EventGallary({
    Key key,
    this.event,
  }) : super(key: key);
  final Event event;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          EventDetailTitle('Event Gallery').paddingBottom(30),
          GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 10,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: MyTheme.cardPadding * 2,
                crossAxisSpacing: MyTheme.cardPadding,
              ),
              itemBuilder: (ctx, index) => Container(
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                      child: ExtendedImage.network(event.coverImageURL ?? "", cache: true, fit: BoxFit.cover,
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
                  )).paddingBottom(32),
        ],
      ),
    );
  }
}
