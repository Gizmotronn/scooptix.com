import 'dart:async';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/buttons/apollo_button.dart';
import 'package:ticketapp/UI/widgets/cards/image_card.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/model/link_type/overview.dart';
import 'package:ticketapp/pages/authentication/authentication_page.dart';
import 'package:ticketapp/utilities/format_date/full_date_time.dart';

class FeaturedEvents extends StatefulWidget {
  final List<Event> events;

  const FeaturedEvents({Key key, @required this.events}) : super(key: key);

  @override
  _FeaturedEventsState createState() => _FeaturedEventsState();
}

class _FeaturedEventsState extends State<FeaturedEvents> {
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
                child: EventFeatures(events: widget.events)),
          ],
        )
      ],
    );
  }
}

class EventFeatures extends StatefulWidget {
  final List<Event> events;
  const EventFeatures({Key key, @required this.events}) : super(key: key);

  @override
  _EventFeaturesState createState() => _EventFeaturesState();
}

class _EventFeaturesState extends State<EventFeatures>
    with SingleTickerProviderStateMixin {
  GlobalKey<AnimatedListState> _list = GlobalKey<AnimatedListState>();

  AnimationController _controller;
  Animation<double> _fadeAnimation;
  Animation<double> _scaleAnimation;

  List<Event> events = [];
  Event event;

  int count = 0;
  double position = -300;

  @override
  void initState() {
    widget.events.forEach((e) {
      if (events.length < 4) {
        events.add(e);
      }
    });

    _controller =
        AnimationController(vsync: this, duration: MyTheme.animationDuration);
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(_controller);
    _animateCard();
    super.initState();
  }

  Future<void> _animateCard() async {
    await Future.delayed(MyTheme.animationDuration);
    _controller.forward();
    setState(() {
      position = -300;
    });

    await Future.delayed(MyTheme.animationDuration);

    setState(() {
      count++;
      event = events[count];
    });
    _list.currentState.removeItem(
        count, (_, animation) => _buildItem(context, count, animation),
        duration: MyTheme.animationDuration);
    events.removeAt(count);
    events.insert(0, event);
    _list.currentState.insertItem(0);
    if (count >= 3) {
      setState(() {
        count = 0;
      });
    }
    _controller.reverse();
    setState(() {
      position = 30;
    });
    await Future.delayed(Duration(seconds: 8));
    _animateCard();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 300,
          width: MediaQuery.of(context).size.width * 0.55,
          child: Row(
            children: [
              Expanded(flex: 2, child: _inComingEvents()),
              Expanded(flex: 7, child: _heroEvent()),
            ],
          ),
        ).paddingAll(16),
        _buildFeaturedText(),
      ],
    );
  }

  Widget _buildFeaturedText() {
    return AnimatedPositioned(
      duration: MyTheme.animationDuration,
      right: position,
      top: 50,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: FeaturedEventText(event: event),
      ),
    );
  }

  Widget _inComingEvents() => Container(
        child: AnimatedList(
          key: _list,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          initialItemCount: events.length,
          itemBuilder: (context, index, animation) =>
              _buildItem(context, index, animation),
        ),
      ).paddingRight(4);

  Widget _heroEvent() => Builder(
        builder: (context) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                child: ExpandImageCard(imageUrl: event?.coverImageURL),
              ),
            ),
          );
        },
      );

  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: Container(
        height: 75,
        child: ExpandImageCard(
          imageUrl: events[index].coverImageURL,
        ),
      ),
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
            color: MyTheme.appolloDimGrey.withOpacity(.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateName(context),
                _buildDescriptionNButton(context),
              ],
            ),
          ).paddingAll(16),
        ),
      ),
    );
  }

  Widget _buildDescriptionNButton(BuildContext context) {
    return Column(
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
                maxLines: 2, style: Theme.of(context).textTheme.button),
            onTap: () {
              final overviewLinkType = OverviewLinkType(event);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => AuthenticationPage(overviewLinkType)));
            }),
      ],
    );
  }

  Widget _buildDateName(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AutoSizeText(
          //TODO To avoid null value I added [DateTime.now()] should be remove.
          fullDate(event?.date ?? DateTime.now()),
          textAlign: TextAlign.start,
          maxLines: 2,
          style: Theme.of(context).textTheme.headline6.copyWith(
              color: MyTheme.appolloRed, letterSpacing: 1.5, fontSize: 12),
        ).paddingBottom(8),
        AutoSizeText(
          event?.name ?? '',
          textAlign: TextAlign.start,
          maxLines: 2,
          style: Theme.of(context)
              .textTheme
              .headline3
              .copyWith(color: MyTheme.appolloGreen),
        ).paddingBottom(4),
      ],
    );
  }
}
