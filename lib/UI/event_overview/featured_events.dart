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
import 'package:ticketapp/pages/event_details/event_detail_page.dart';
import 'package:ticketapp/repositories/events_repository.dart';
import 'package:ticketapp/services/navigator_services.dart';
import 'package:ticketapp/utilities/format_date/full_date_time.dart';
import 'package:visibility_detector/visibility_detector.dart';

class FeaturedEvents extends StatefulWidget {
  @override
  _FeaturedEventsState createState() => _FeaturedEventsState();
}

class _FeaturedEventsState extends State<FeaturedEvents> {
  List<Event> events = [];

  @override
  void initState() {
    super.initState();

    events = EventsRepository.instance.events;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: kToolbarHeight + 20),
            Container(width: screenSize.width * 0.8, child: EventFeatures(events: events)),
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

class _EventFeaturesState extends State<EventFeatures> with SingleTickerProviderStateMixin {
  GlobalKey<AnimatedListState> _list = GlobalKey<AnimatedListState>();

  AnimationController _controller;
  Animation<double> _fadeAnimation;
  Animation<double> _scaleAnimation;

  List<Event> events = [];
  Event event;

  int count = 0;
  double position = -300;
  double endPosition = 100;

  int visibilityPercentage = 0;

  Timer _timer;

  @override
  void initState() {
    widget.events.forEach((e) {
      if (events.length < 4) {
        events.add(e);
      }
    });

    _controller = AnimationController(vsync: this, duration: MyTheme.animationDuration);
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(_controller);
    _animatedCard();
    super.initState();
  }

  void _animatedCard() {
    if (_timer != null) {
      _timer.cancel();
    }
    _timer = Timer.periodic(Duration(seconds: 6), (timer) async {
      if (!this.mounted) {
        _timer.cancel();
        count = 0;
        return;
      }
      await Future.delayed(Duration(milliseconds: 300));
      _controller.forward();
      setState(() => position = -300);
      await Future.delayed(Duration(milliseconds: 300));
      setState(() {
        count++;
        event = events[count];
      });
      _list.currentState.removeItem(count, (_, animation) => _buildItem(context, count, animation),
          duration: MyTheme.animationDuration);
      events.removeAt(count);
      events.insert(0, event);
      _list.currentState.insertItem(0);
      if (count >= 3) {
        setState(() => count = 0);
      }
      _controller.reverse();
      setState(() => position = endPosition);
      if (visibilityPercentage < 30) {
        _timer?.cancel();
        timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return VisibilityDetector(
      onVisibilityChanged: (VisibilityInfo info) {
        var visiblePercentage = info.visibleFraction * 100;
        setState(() {
          visibilityPercentage = visiblePercentage.toInt();
        });
        if (visibilityPercentage > 25) {
          _animatedCard();
        }
      },
      key: ValueKey('visible-key'),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: screenSize.height * 0.4,
            width: screenSize.width * 0.55,
            child: Row(
              children: [
                Expanded(flex: 2, child: _inComingEvents()),
                Expanded(flex: 7, child: _heroEvent()),
              ],
            ),
          ).paddingAll(16),
          _buildFeaturedText(screenSize),
        ],
      ),
    );
  }

  Widget _buildFeaturedText(Size screenSize) {
    final featureEventCardHeight = screenSize.height * 0.4;
    final featureEventCardWidth = screenSize.width * 0.55;
    endPosition = featureEventCardWidth * 0.2;

    return AnimatedPositioned(
      duration: MyTheme.animationDuration,
      right: position,
      top: featureEventCardHeight * 0.2,
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
          itemBuilder: (context, index, animation) => _buildItem(context, index, animation),
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

  Widget _buildItem(BuildContext context, int index, Animation<double> animation) {
    final featureEventCardHeight = MediaQuery.of(context).size.height * 0.4;
    return FadeTransition(
      opacity: animation,
      child: Container(
        height: featureEventCardHeight / 4,
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
            color: MyTheme.appolloGrey.withOpacity(.4),
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
          "${event.description}",
          textAlign: TextAlign.start,
          maxLines: 2,
          style: Theme.of(context).textTheme.caption.copyWith(color: MyTheme.appolloWhite, fontSize: 14),
        ).paddingBottom(8),
        AppolloButton.wideButton(
            heightMax: 40,
            heightMin: 35,
            color: MyTheme.appolloGreen,
            child: AutoSizeText('Get Your Ticket', maxLines: 2, style: Theme.of(context).textTheme.button),
            onTap: () {
              final overviewLinkType = OverviewLinkType(event);
              NavigationService.navigateTo(EventDetail.routeName,
                  arg: overviewLinkType.event.docID, queryParams: {'id': overviewLinkType.event.docID});
              // Navigator.of(context).push(MaterialPageRoute(builder: (_) => AuthenticationPage(overviewLinkType)));
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
          style: Theme.of(context)
              .textTheme
              .headline6
              .copyWith(color: MyTheme.appolloRed, letterSpacing: 1.5, fontSize: 12),
        ).paddingBottom(8),
        AutoSizeText(
          event?.name ?? '',
          textAlign: TextAlign.start,
          maxLines: 2,
          style: Theme.of(context).textTheme.headline3.copyWith(color: MyTheme.appolloWhite),
        ).paddingBottom(4),
      ],
    );
  }
}
