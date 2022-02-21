import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:ticketapp/UI/widgets/appollo/appollo_progress_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../UI/widgets/appollo/appollo_divider.dart';
import '../../../model/event.dart';
import '../../../UI/theme.dart';

class EventCustomInfo extends StatelessWidget {
  const EventCustomInfo({
    Key? key,
    required this.event,
  }) : super(key: key);

  final Event event;

  @override
  Widget build(BuildContext context) {
    if (event.customEventInfo.isEmpty) {
      return SizedBox.shrink();
    } else {
      return SizedBox(
        width: MyTheme.maxWidth,
        height: (MyTheme.maxWidth / 3 - MyTheme.elementSpacing * 2 / 3) * event.customEventInfo.length + 141,
        child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          itemExtent: MyTheme.maxWidth / 3 - MyTheme.elementSpacing * 2 / 3 + 141,
          itemCount: event.customEventInfo.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                AutoSizeText(
                  event.customEventInfo[index].headline,
                  style: MyTheme.textTheme.headline4!.copyWith(color: MyTheme.scoopOrange, fontWeight: FontWeight.w600),
                ).paddingBottom(MyTheme.elementSpacing),
                SizedBox(
                  width: MyTheme.maxWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(min(3, event.customEventInfo[index].imageUrls.length), (i) {
                      return SizedBox(
                        width: MyTheme.maxWidth / 3 - MyTheme.elementSpacing * 2 / 3,
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: InkWell(
                            onTap: () async {
                              print(event.customEventInfo[index].targetUrls[i]);
                              if (await canLaunch(event.customEventInfo[index].targetUrls[i])) {
                                await launch(event.customEventInfo[index].targetUrls[i]);
                              }
                            },
                            child: ExtendedImage.network(event.customEventInfo[index].imageUrls[i],
                                cache: false, fit: BoxFit.fitWidth, loadStateChanged: (ExtendedImageState state) {
                              switch (state.extendedImageLoadState) {
                                case LoadState.loading:
                                  return Center(
                                    child: SizedBox(height: 64, width: 64, child: AppolloProgressIndicator()),
                                  );
                                case LoadState.completed:
                                  return state.completedWidget;
                                default:
                                  return Container(
                                    color: Colors.white,
                                  );
                              }
                            }),
                          ).paddingLeft(i == 0 ? 0 : MyTheme.elementSpacing),
                        ),
                      );
                    }),
                  ),
                ),
                AppolloDivider(),
              ],
            );
          },
        ),
      );
    }
  }
}
