import 'dart:async';

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/buttons/apollo_button.dart';
import 'package:ticketapp/UI/widgets/cards/image_card.dart';
import 'package:ticketapp/model/event.dart';
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

class _FeaturedEventsMobileState extends State<FeaturedEventsMobile> with TickerProviderStateMixin {
  GlobalKey<AnimatedListState> _list = GlobalKey<AnimatedListState>();

  Duration _animationDuration = Duration(milliseconds: 300);
  List<Event> events = [];
  Event heroEvent;

  AnimationController _animationController;
  int visibilityPercentage = 0;

  Timer _timer;
  int count = 0;

  Offset beginOffset = Offset(0, 0);

  Offset endOffset = Offset(-2, 0);

  @override
  void initState() {
    _animationController = AnimationController(vsync: this, duration: _animationDuration);
    for (int i = 0; i < 5 && i < widget.events.length; i++) {
      events.add(widget.events[i]);
    }
    heroEvent = events.first;
    super.initState();
    _animatedCard();
  }

  slideList() async {
    var removedEvent = events.removeAt(0);

    await _animationController.forward();

    setState(() {
      beginOffset = Offset(0, 0);
      endOffset = Offset(2, 0);
      heroEvent = removedEvent;
      events.add(removedEvent);
    });
    await _animationController.reverse();
    setState(() {
      beginOffset = Offset(0, 0);
      endOffset = Offset(-2, 0);
    });
  }

  void _animatedCard() {
    print("animated");
    if (_timer != null) {
      _timer.cancel();
    }
    _timer = Timer.periodic(Duration(seconds: 6), (timer) async {
      slideList();
      if (visibilityPercentage <= 25) {
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

        if (visiblePercentage.toInt() > 25 && visibilityPercentage <= 25) {
          _animatedCard();
        }
        if (visibilityPercentage != visiblePercentage.toInt()) {
          setState(() {
            visibilityPercentage = visiblePercentage.toInt();
          });
        }
      },
      key: ValueKey('visible-key2'),
      child: Builder(builder: (context) {
        return Container(
          child: Column(children: [
            const SizedBox(height: kToolbarHeight + 8),
            heroEvent == null
                ? SizedBox()
                : SlideTransition(
                    position: Tween<Offset>(begin: beginOffset, end: endOffset)
                        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(
                            aspectRatio: 1.9,
                            child: ExpandImageCard(
                              imageUrl: heroEvent.coverImageURL,
                              borderRadius: BorderRadius.zero,
                            )).paddingBottom(16),
                        heroEvent == null ? SizedBox() : FeaturedEventTextMobile(event: heroEvent).paddingBottom(16),
                      ],
                    ),
                  ),
            _buildButton(),
            SizedBox(height: 50, child: _inComingEvents(context)).paddingBottom(16).paddingHorizontal(16),
          ]),
        );
      }),
    );
  }

  Widget _buildButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppolloButton.regularButton(
            color: MyTheme.appolloGreen,
            child: AutoSizeText('Get Ticket',
                maxLines: 2, style: Theme.of(context).textTheme.button.copyWith(color: MyTheme.appolloBlack)),
            onTap: () {
              NavigationService.navigateTo(EventDetailPage.routeName,
                  arg: heroEvent.docID, queryParams: {'id': heroEvent.docID});
              // Navigator.of(context).push(MaterialPageRoute(builder: (_) => AuthenticationPage(overviewLinkType)));
            }),
      ],
    ).paddingHorizontal(16).paddingBottom(16);
  }

  Widget _inComingEvents(BuildContext context) {
    return Container(
      child: AnimatedList(
        key: _list,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        physics: NeverScrollableScrollPhysics(),
        initialItemCount: events.length,
        itemBuilder: (context, index, animation) => _buildItem(context, index, animation),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index, Animation<double> animation) {
    final size = MediaQuery.of(context).size;

    return SlideTransition(
      position: Tween<Offset>(
              begin: _animationController.status == AnimationStatus.forward && index == 3 ? Offset(5, 0) : Offset(0, 0),
              end: _animationController.status == AnimationStatus.forward && index == 0 ? Offset(-5, 0) : Offset(0, 0))
          .animate(_animationController),
      child: SizedBox(
        width: size.width * 0.233,
        child: ExpandImageCard(
          imageUrl: events[index].coverImageURL,
        ).paddingRight(2.5).paddingLeft(index == 4 ? 30 : 0),
      ),
    );
  }
}

class FeaturedEventTextMobile extends StatelessWidget {
  final Event event;

  const FeaturedEventTextMobile({Key key, @required this.event}) : super(key: key);
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
          style: MyTheme.lightTextTheme.caption.copyWith(color: MyTheme.appolloRed, letterSpacing: 1.5),
        ).paddingBottom(8),
        AutoSizeText(
          event?.name ?? '',
          textAlign: TextAlign.start,
          maxLines: 2,
          style: MyTheme.lightTextTheme.headline5.copyWith(color: MyTheme.appolloGreen),
        ).paddingBottom(8),
        AutoSizeText(
          "${event?.description ?? ''}",
          textAlign: TextAlign.start,
          maxLines: 2,
          style: MyTheme.lightTextTheme.bodyText1.copyWith(fontWeight: FontWeight.w400),
        ).paddingBottom(8)
      ],
    );
  }
}
