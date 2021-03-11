import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/buttons/apollo_button.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/utilities/format_date/full_date_time.dart';

class FeaturedEvents extends StatelessWidget {
  final List<Event> events;

  const FeaturedEvents({
    Key key,
    @required this.events,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: kToolbarHeight + 20,
            ),
            Container(
              width: screenSize.width * 0.8,
              child: Stack(
                children: [
                  EventFeatures(events: events),
                  Positioned(
                      right: 50,
                      top: 50,
                      child: FeaturedEventText(event: events[0])),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class EventFeatures extends StatelessWidget {
  final List<Event> events;

  const EventFeatures({
    Key key,
    @required this.events,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: MediaQuery.of(context).size.width * 0.55,
      child: Row(
        children: [
          _inComingEvents(),
          _heroEvent(),
        ],
      ),
    ).paddingAll(16);
  }

  Widget _inComingEvents() => Container(
        child: Column(
          children: List.generate(
            4,
            (index) => ExpandImageCard(imageUrl: events[index].coverImageURL),
          ),
        ),
      ).paddingRight(4);
  Widget _heroEvent() => Container(
        child: ExpandImageCard(imageUrl: events[0].coverImageURL),
      );
}

class ExpandImageCard extends StatelessWidget {
  const ExpandImageCard({
    Key key,
    @required this.imageUrl,
  }) : super(key: key);

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: 150,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
                fit: BoxFit.cover,
                image: ExtendedImage.network(imageUrl ??
                        'https://media.istockphoto.com/vectors/abstract-pop-art-line-and-dots-color-pattern-background-vector-liquid-vector-id1017781486?k=6&m=1017781486&s=612x612&w=0&h=nz4YljNqJ0xjxcdVVJge3dW3cqNakWjG7u2oFqW4tjs=')
                    .image)),
      ).paddingAll(4),
    );
  }
}

class FeaturedEventText extends StatelessWidget {
  final Event event;

  const FeaturedEventText({Key key, @required this.event}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 16,
          sigmaY: 16,
        ),
        child: Container(
          height: 225,
          width: 400,
          decoration: BoxDecoration(
            color: MyTheme.appolloWhite.withOpacity(.1),
            border: Border.all(
              width: 0.5,
              color: MyTheme.appolloWhite.withOpacity(.4),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      fullDate(event.date) ?? '',
                      textAlign: TextAlign.start,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.headline6.copyWith(
                          color: MyTheme.appolloRed,
                          letterSpacing: 1.5,
                          fontSize: 12),
                    ).paddingBottom(8),
                    AutoSizeText(
                      event.name ?? '',
                      textAlign: TextAlign.start,
                      maxLines: 2,
                      style: Theme.of(context)
                          .textTheme
                          .headline3
                          .copyWith(color: MyTheme.appolloWhite),
                    ).paddingBottom(4),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AutoSizeText(
                      """Proin eget tortor risus. Praesent sapien massa, convallis a pellentesque nec, egestas non nisi.""",
                      textAlign: TextAlign.start,
                      maxLines: 2,
                      style: Theme.of(context)
                          .textTheme
                          .caption
                          .copyWith(color: MyTheme.appolloWhite, fontSize: 14),
                    ).paddingBottom(8),
                    AppolloButton.wideButton(
                        heightMax: 40,
                        heightMin: 35,
                        color: MyTheme.appolloGreen,
                        child: AutoSizeText('Get Your Ticket',
                            maxLines: 2,
                            style: Theme.of(context).textTheme.button),
                        onTap: () {}),
                  ],
                ),
              ],
            ),
          ).paddingAll(16),
        ),
      ),
    );
  }
}
