import 'dart:async';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:ticketapp/UI/services/navigator_services.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/cards/image_card.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/pages/event_details/event_detail_page.dart';
import 'package:ticketapp/utilities/format_date/full_date_time.dart';
import 'package:ui_basics/ui_basics.dart';
import 'package:visibility_detector/visibility_detector.dart';

class FeaturedEventsDesktop extends StatefulWidget {
  final List<Event> events;
  const FeaturedEventsDesktop({Key? key, required this.events})
      : super(key: key);

  @override
  _FeaturedEventsDesktopState createState() => _FeaturedEventsDesktopState();
}

class _FeaturedEventsDesktopState extends State<FeaturedEventsDesktop>
    with SingleTickerProviderStateMixin {
  GlobalKey<AnimatedListState> _list = GlobalKey<AnimatedListState>();

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  List<Event> events = [];
  late Event event;

  int count = 0;
  double position = 0;

  int visibilityPercentage = 0;

  Timer? _timer;

  @override
  void initState() {
    widget.events.forEach((e) {
      if (events.length < 4) {
        events.add(e);
      }
    });
    if (events.length != 0) {
      event = events.first;
      _controller =
          AnimationController(vsync: this, duration: MyTheme.animationDuration);
      _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller);
      _scaleAnimation =
          Tween<double>(begin: 1.0, end: 0.9).animate(_controller);
      Future.delayed(Duration(milliseconds: 1000), () {
        setState(() => position = 0);
        _animatedCard();
      });
    }
    super.initState();
  }

  void _animatedCard() {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer.periodic(Duration(seconds: 6), (timer) async {
      if (!this.mounted) {
        _timer!.cancel();
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
      _list.currentState!.removeItem(
          count, (_, animation) => _buildItem(context, count, animation),
          duration: MyTheme.animationDuration);
      events.removeAt(count);
      events.insert(0, event);
      _list.currentState!.insertItem(0);
      if (count >= 3) {
        setState(() => count = 0);
      }
      _controller.reverse();
      setState(() => position = 0);
      if (visibilityPercentage < 30) {
        _timer?.cancel();
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (events.length == 0) {
      return SizedBox.shrink();
    }
    final screenSize = MediaQuery.of(context).size;
    final double height = 380;
    final width = MyTheme.maxWidth * 0.9;

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
      child: events.isEmpty
          ? SizedBox(
              height: height,
              width: width,
            )
          : Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: height,
                  // width: width,
                  child: Row(
                    children: [
                      SizedBox(
                          height: 380, width: 190, child: _inComingEvents()),
                      SizedBox(
                          height: 380,
                          child: AspectRatio(
                              aspectRatio: 1.9, child: _heroEvent())),
                    ],
                  ),
                ).paddingAll(16),
                _buildFeaturedText(screenSize),
              ],
            ).paddingBottom(MyTheme.elementSpacing),
    );
  }

  Widget _buildFeaturedText(Size screenSize) {
    final featureEventCardHeight = 380;

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
          itemBuilder: (context, index, animation) =>
              _buildItem(context, index, animation),
        ),
      ).paddingRight(4);

  Widget _heroEvent() => Builder(
        builder: (context) {
          final double featureEventCardHeight = 380;
          return FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: InkWell(
                onTap: () {
                  NavigationService.navigateTo(EventDetailPage.routeName,
                      arg: event.docID, queryParams: {'id': event.docID!});
                },
                child: Container(
                  height: featureEventCardHeight,
                  child: AspectRatio(
                      aspectRatio: 1.9,
                      child: ExpandImageCard(imageUrl: event.coverImageURL)
                          .paddingAll(2.5)),
                ),
              ),
            ),
          );
        },
      );

  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation) {
    final featureEventCardHeight = 380;
    return FadeTransition(
      opacity: animation,
      child: Container(
        height: featureEventCardHeight / 4,
        child: AspectRatio(
          aspectRatio: 1.9,
          child: ExpandImageCard(
            imageUrl: events[index].coverImageURL,
          ).paddingAll(2.5),
        ),
      ),
    );
  }
}

class FeaturedEventText extends StatelessWidget {
  final Event event;

  const FeaturedEventText({Key? key, required this.event}) : super(key: key);
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
            color: MyTheme.scoopCardColor.withOpacity(.7),
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
          "${event.summary}",
          textAlign: TextAlign.start,
          maxLines: 2,
          style: MyTheme.textTheme.bodyText1,
        ).paddingBottom(8),
        ScoopButton(
            buttonTheme: ScoopButtonTheme.secondary,
            title: 'View Event',
            onTap: () {
              NavigationService.navigateTo(EventDetailPage.routeName,
                  arg: event.docID, queryParams: {'id': event.docID!});
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
          fullDateWithDay(event.date),
          textAlign: TextAlign.start,
          maxLines: 2,
          style: MyTheme.textTheme.headline6!
              .copyWith(color: MyTheme.scoopRed, letterSpacing: 1.5),
        ).paddingBottom(8),
        AutoSizeText(
          event.name,
          textAlign: TextAlign.start,
          maxLines: 2,
          style:
              MyTheme.textTheme.headline2!.copyWith(color: MyTheme.scoopWhite),
        ).paddingBottom(4),
      ],
    );
  }
}
