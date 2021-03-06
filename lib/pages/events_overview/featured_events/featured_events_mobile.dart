import 'dart:async';

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:ticketapp/UI/services/navigator_services.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/cards/image_card.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/pages/event_details/event_detail_page.dart';
import 'package:ticketapp/utilities/format_date/full_date_time.dart';
import 'package:ui_basics/ui_basics.dart';
import 'package:visibility_detector/visibility_detector.dart';

class FeaturedEventsMobile extends StatefulWidget {
  final List<Event> events;
  const FeaturedEventsMobile({Key? key, required this.events})
      : super(key: key);
  @override
  _FeaturedEventsMobileState createState() => _FeaturedEventsMobileState();
}

class _FeaturedEventsMobileState extends State<FeaturedEventsMobile>
    with TickerProviderStateMixin {
  GlobalKey<AnimatedListState> _list = GlobalKey<AnimatedListState>();

  Duration _animationDuration = Duration(milliseconds: 300);
  List<Event> events = [];
  Event? heroEvent;

  late AnimationController _animationController;
  int visibilityPercentage = 0;

  Timer? _timer;
  int count = 0;

  Offset beginOffset = Offset(0, 0);

  Offset endOffset = Offset(-2, 0);

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: _animationDuration);
    for (int i = 0; i < 5 && i < widget.events.length; i++) {
      events.add(widget.events[i]);
    }
    heroEvent = events.first;
    super.initState();
    _animatedCard();
  }

  slideList() async {
    await _animationController.forward();
    var removedEvent = events.removeAt(0);

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
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer.periodic(Duration(seconds: 6), (timer) async {
      slideList();
      if (visibilityPercentage <= 25) {
        _timer?.cancel();
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer!.cancel();
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
            heroEvent == null
                ? SizedBox()
                : SlideTransition(
                    position: Tween<Offset>(begin: beginOffset, end: endOffset)
                        .animate(CurvedAnimation(
                            parent: _animationController,
                            curve: Curves.easeInOut)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(
                            aspectRatio: 1.9,
                            child: InkWell(
                              onTap: () {
                                NavigationService.navigateTo(
                                    EventDetailPage.routeName,
                                    arg: heroEvent!.docID,
                                    queryParams: {'id': heroEvent!.docID!});
                              },
                              child: ExpandImageCard(
                                imageUrl: heroEvent!.coverImageURL,
                                borderRadius: BorderRadius.zero,
                              ),
                            )).paddingBottom(16),
                        heroEvent == null
                            ? SizedBox()
                            : FeaturedEventTextMobile(event: heroEvent!)
                                .paddingBottom(16),
                      ],
                    ),
                  ),
            _buildButton(),
            SizedBox(
                    height: MediaQuery.of(context).size.width / 4 / 1.9,
                    child: _inComingEvents(context))
                .paddingBottom(16)
                .paddingHorizontal(16),
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
        ScoopButton(
            buttonTheme: ScoopButtonTheme.secondary,
            title: 'View Event',
            onTap: () {
              NavigationService.navigateTo(EventDetailPage.routeName,
                  arg: heroEvent!.docID,
                  queryParams: {'id': heroEvent!.docID!});
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
        itemBuilder: (context, index, animation) =>
            _buildItem(context, index, animation),
      ),
    );
  }

  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation) {
    final size = MediaQuery.of(context).size;

    return SlideTransition(
      position: Tween<Offset>(
              begin: _animationController.status == AnimationStatus.forward &&
                      index == 3
                  ? Offset(5, 0)
                  : Offset(0, 0),
              end: _animationController.status == AnimationStatus.forward &&
                      index == 0
                  ? Offset(-5, 0)
                  : Offset(0, 0))
          .animate(_animationController),
      child: SizedBox(
        width: size.width * 0.25 - 8,
        child: AspectRatio(
          aspectRatio: 1.9,
          child: ExpandImageCard(
            imageUrl: events[index].coverImageURL,
          ).paddingRight(index == 3 ? 0 : 8),
        ),
      ),
    );
  }
}

class FeaturedEventTextMobile extends StatelessWidget {
  final Event event;

  const FeaturedEventTextMobile({Key? key, required this.event})
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
          fullDateWithDay(event.date),
          textAlign: TextAlign.start,
          maxLines: 2,
          style: MyTheme.textTheme.caption!.copyWith(color: MyTheme.scoopRed),
        ).paddingBottom(8),
        AutoSizeText(
          event.name,
          textAlign: TextAlign.start,
          maxLines: 2,
          style:
              MyTheme.textTheme.headline5!.copyWith(color: MyTheme.scoopGreen),
        ).paddingBottom(8),
        AutoSizeText(
          "${event.summary}",
          textAlign: TextAlign.start,
          maxLines: 2,
          style: MyTheme.textTheme.bodyText1!
              .copyWith(fontWeight: FontWeight.w400),
        ).paddingBottom(8)
      ],
    );
  }
}
