import 'package:auto_size_text/auto_size_text.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:ticketapp/model/link_type/overview.dart';
import 'package:ticketapp/pages/event_details/authentication_drawer.dart';
import 'package:ticketapp/pages/event_details/checkout_drawer.dart';
import 'package:ticketapp/repositories/user_repository.dart';

import '../../../UI/theme.dart';
import '../../../main.dart';
import '../../../model/event.dart';

class EventDetailNavbar extends StatelessWidget {
  const EventDetailNavbar({
    Key key,
    @required this.event,
  }) : super(key: key);

  final Event event;
  final double bottomBarHeight = 48.0;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: MyTheme.maxWidth,
        height: bottomBarHeight,
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      image: DecorationImage(
                        image: ExtendedImage.network(
                          event.coverImageURL ??
                              'https://designshack.net/wp-content/uploads/party-club-flyer-templates.jpg',
                          cache: true,
                        ).image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ).paddingRight(16),
                  AutoSizeText(
                    event.name,
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        .copyWith(color: MyTheme.appolloGreen, fontWeight: FontWeight.w600),
                  ),
                ],
              ).paddingLeft(8).paddingVertical(8),
              InkWell(
                onTap: () {},
                child: Container(
                  height: bottomBarHeight,
                  decoration: BoxDecoration(
                      color: MyTheme.appolloGreen, borderRadius: BorderRadius.only(topRight: Radius.circular(5))),
                  child: Center(
                    child: Text('Get Tickets',
                            style: Theme.of(context)
                                .textTheme
                                .button
                                .copyWith(fontWeight: FontWeight.w500, color: MyTheme.appolloBackgroundColor))
                        .paddingHorizontal(16),
                  ),
                ),
              ),
            ],
          ),
        ).appolloCard(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(5),
            topRight: Radius.circular(5),
          ),
          color: MyTheme.appolloCardColor.withAlpha(190),
        ),
      ),
    );
  }
}
