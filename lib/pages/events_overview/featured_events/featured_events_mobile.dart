import 'dart:async';

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/buttons/apollo_button.dart';
import 'package:ticketapp/UI/widgets/cards/image_card.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/model/link_type/overview.dart';
import 'package:ticketapp/pages/event_details/event_detail_page.dart';
import 'package:ticketapp/services/navigator_services.dart';
import 'package:ticketapp/utilities/format_date/full_date_time.dart';
import 'package:visibility_detector/visibility_detector.dart';

class FeaturedEventsMobile extends StatefulWidget {
  final List<Event> events;
  const FeaturedEventsMobile({Key key, this.events}) : super(key: key);
  @override
  _FeaturedEventsMobileState createState() => _FeaturedEventsMobileState();
}

class _FeaturedEventsMobileState extends State<FeaturedEventsMobile>
    with TickerProviderStateMixin {

  Duration _animationDuration = Duration(milliseconds: 400);
  List<Event> events = [];
  Event heroEvent;

  AnimationController _animationController;
  ScrollController _scrollController;
  int visibilityPercentage = 0;

  Timer _timer;
  int count = 0;


  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: _animationDuration);
    _scrollController = ScrollController();
    widget.events.forEach((element) {
      if (events.length < 5) {
        events.add(element);
      }
    });
    heroEvent = events.first;
    super.initState();
    _animatedCard();
  }

  slideList() async {
    var removedEvent = events.removeAt(0);
    await _animationController.forward(from: 0.8);

    setState(() {
      heroEvent = removedEvent;
    });

    setState(() {
      events.insert(4, removedEvent);
    });
    if (_animationController.status == AnimationStatus.completed) {
      _animationController.reset();
    }
  }

  void _animatedCard() {
    if (_timer != null) {
      _timer.cancel();
    }
    _timer = Timer.periodic(Duration(seconds: 6), (timer) async {
      slideList();
      if (visibilityPercentage < 30) {
        _timer?.cancel();
        timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      key: ValueKey('visible-key2'),
      child: Container(
        child: Column(children: [
          const SizedBox(height: kToolbarHeight + 8),
          heroEvent == null
              ? SizedBox()
              : SlideTransition(
                  position: TweenSequence<Offset>(<TweenSequenceItem<Offset>>[
                    TweenSequenceItem<Offset>(
                        tween: Tween(begin: Offset(0, 0), end: Offset(5, 0)),
                        weight: 15),
                    TweenSequenceItem<Offset>(
                        tween: Tween(begin: Offset(-5, 0), end: Offset(0, 0)),
                        weight: 15)
                  ]).animate(CurvedAnimation(
                      parent: _animationController, curve: Curves.easeInOut)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                          aspectRatio: 1.9,
                          child: ExpandImageCard(
                            imageUrl: heroEvent.coverImageURL,
                            borderRadius: BorderRadius.zero,
                          )).paddingBottom(16),
                      heroEvent == null
                          ? SizedBox()
                          : FeaturedEventTextMobile(event: heroEvent)
                              .paddingBottom(16),
                    ],
                  ),
                ),
          _buildButton(),
          SizedBox(height: 50, child: _inComingEvents(context))
              .paddingBottom(16)
              .paddingHorizontal(16),
        ]),
      ),
    );
  }

  Widget _buildButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppolloButton.wideButton(
            heightMax: 45,
            heightMin: 40,
            color: MyTheme.appolloGreen,
            child: AutoSizeText('Get Ticket',
                maxLines: 2,
                style: Theme.of(context)
                    .textTheme
                    .button
                    .copyWith(color: MyTheme.appolloBlack)),
            onTap: () {
              final overviewLinkType = OverviewLinkType(heroEvent);
              NavigationService.navigateTo(EventDetailPage.routeName,
                  arg: overviewLinkType.event.docID,
                  queryParams: {'id': overviewLinkType.event.docID});
              // Navigator.of(context).push(MaterialPageRoute(builder: (_) => AuthenticationPage(overviewLinkType)));
            }),
      ],
    ).paddingHorizontal(16).paddingBottom(16);
  }

  Widget _inComingEvents(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      child: Container(
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: NeverScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              events.length,
              (index) => SizedBox(
                width: size.width * 0.233,
                child: ExpandImageCard(
                  imageUrl: events[index].coverImageURL,
                ).paddingRight(index == 3?10:2.5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FeaturedEventTextMobile extends StatelessWidget {
  final Event event;

  const FeaturedEventTextMobile({Key key, @required this.event})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      child: Container(
        child: _buildDateName(context),
      ).paddingHorizontal(16),
    );
  }

  Widget _buildDateName(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AutoSizeText(
          event?.date == null ? '' : fullDate(event?.date),
          textAlign: TextAlign.start,
          maxLines: 2,
          style: MyTheme.lightTextTheme.caption
              .copyWith(color: MyTheme.appolloRed, letterSpacing: 1.5),
        ).paddingBottom(8),
        AutoSizeText(
          event?.name ?? '',
          textAlign: TextAlign.start,
          maxLines: 2,
          style: MyTheme.lightTextTheme.headline5
              .copyWith(color: MyTheme.appolloGreen),
        ).paddingBottom(8),
        AutoSizeText(
          "${event?.description ?? ''}",
          textAlign: TextAlign.start,
          maxLines: 2,
          style: MyTheme.lightTextTheme.bodyText1.copyWith(fontWeight:FontWeight.w400),
        ).paddingBottom(8)
      ],
    );
  }
}
