import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:ticketapp/UI/event_overview/event_overview_home.dart';
import 'package:ticketapp/UI/widgets/appollo/appolloDivider.dart';
import 'package:ticketapp/UI/widgets/buttons/apollo_button.dart';
import 'package:ticketapp/UI/widgets/buttons/card_button.dart';
import 'package:ticketapp/UI/widgets/cards/appollo_bg_card.dart';
import 'package:ticketapp/model/organizer.dart';
import 'package:ticketapp/pages/event_details/widget/detail_with_button.dart';
import '../../../UI/theme.dart';
import '../../../UI/widgets/buttons/side_buttons.dart';
import '../../../model/event.dart';
import 'counter.dart';
import 'event_description.dart';
import 'event_gallery.dart';
import 'event_title.dart';
import 'make_booking.dart';
import 'pre_sale_registration.dart';
import 'similar_other_events.dart';

class EventDetailInfo extends StatefulWidget {
  final Event event;
  final Organizer organizer;
  final ScrollController scrollController;
  const EventDetailInfo({Key key, this.event, this.organizer, this.scrollController}) : super(key: key);

  @override
  _EventDetailInfoState createState() => _EventDetailInfoState();
}

class _EventDetailInfoState extends State<EventDetailInfo> {
  List<Menu> _tabButtons = [
    Menu('Detail', false),
    Menu('Pre-Sale', false),
    Menu('Tickets', false),
    Menu('Make a Booking', false),
    Menu('Location', false)
  ];

  List<double> positions = [];
  @override
  void initState() {
    super.initState();
    _tabButtons.forEach((element) {
      positions.add(0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Column(
      children: [
        _eventImageDays(context, screenSize),
        _mainBody(context).paddingBottom(320),
        SimilarOtherEvents(event: widget.event),
      ],
    );
  }

  Widget _mainBody(BuildContext context) => Container(
        child: Column(
          children: [
            BoxOffset(
              boxOffset: (offset) {
                setState(() {
                  positions[0] = offset.dy;
                });
              },
              child: _buildEventDetailWithCountdown(context),
            ),
            BoxOffset(
              boxOffset: (offset) {
                setState(() {
                  positions[1] = offset.dy;
                });
              },
              child: EventDescription(event: widget.event),
            ),
            BoxOffset(
              boxOffset: (offset) {
                setState(() {
                  positions[2] = offset.dy;
                });
              },
              child: PreSaleRegistration(event: widget.event),
            ),
            BoxOffset(
              boxOffset: (offset) {
                setState(() {
                  positions[3] = offset.dy;
                });
              },
              child: MakeBooking(event: widget.event),
            ),
            BoxOffset(
              boxOffset: (offset) {
                positions[4] = offset.dy;
              },
              child: EventGallary(event: widget.event),
            ),
          ],
        ).paddingAll(MyTheme.cardPadding),
      ).appolloCard(color: MyTheme.appolloDarkBlue);

  Widget _buildEventDetailWithCountdown(BuildContext context) {
    return Container(
      child: Column(
        children: [
          EventDetailWithButtons(
            event: widget.event,
            organizer: widget.organizer,
            buttons: List.generate(
              _tabButtons.length,
              (index) => CardButton(
                title: _tabButtons[index].title,
                width: 175,
                borderRadius: BorderRadius.circular(5),
                activeColor: MyTheme.appolloGreen,
                deactiveColor: MyTheme.appolloGrey.withAlpha(140),
                activeColorText: MyTheme.appolloWhite,
                deactiveColorText: MyTheme.appolloGreen,
                onTap: () async {
                  await widget.scrollController
                      .animateTo(positions[index] - 100, curve: Curves.linear, duration: MyTheme.animationDuration);
                },
              ),
            ),
          ),
          EventDetailTitle('Countdown to Pre-Sale Registration').paddingBottom(32),
          _buildCountdown().paddingBottom(32),
          AppolloButton.wideButton(
            heightMax: 40,
            heightMin: 40,
            child: Center(
              child: Text(
                'REMIND ME',
                style: Theme.of(context).textTheme.button.copyWith(color: MyTheme.appolloDarkBlue),
              ),
            ),
            onTap: () {},
            color: MyTheme.appolloGreen,
          ),
          const SizedBox(height: 32),
          AppolloDivider(),
        ],
      ),
    );
  }

  Widget _buildCountdown() {
    return SizedBox(
      width: 432,
      child: Container(
        child: Row(
          children: [
            Expanded(
                child: AppolloCounter(
                    duration: _duration(widget.event.date),
                    countDownType:
                        _duration(widget.event.date).inDays <= 1 ? CountDownType.inHours : CountDownType.inDays)),
            const SizedBox(width: 8),
            Expanded(
                child: AppolloCounter(
                    duration: _duration(widget.event.date),
                    countDownType:
                        _duration(widget.event.date).inDays <= 1 ? CountDownType.inMinutes : CountDownType.inHours)),
            const SizedBox(width: 8),
            Expanded(
                child: AppolloCounter(
                    duration: _duration(widget.event.date),
                    countDownType:
                        _duration(widget.event.date).inDays <= 1 ? CountDownType.inSeconds : CountDownType.inMinutes)),
          ],
        ).paddingAll(8),
      ).appolloCard(),
    );
  }

  Widget _eventImageDays(BuildContext context, Size screenSize) {
    return Column(
      children: [
        SizedBox(height: MediaQuery.of(context).viewPadding.top + 100),
        Container(
          width: MyTheme.maxWidth,
          // height: 603.35,
          child: AspectRatio(
            aspectRatio: 1.9,
            child: Card(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(6)),
                child: ExtendedImage.network(widget.event.coverImageURL ?? "", cache: true, fit: BoxFit.cover,
                    loadStateChanged: (ExtendedImageState state) {
                  switch (state.extendedImageLoadState) {
                    case LoadState.loading:
                      return Container(color: Colors.white);
                    case LoadState.completed:
                      return state.completedWidget;
                    default:
                      return Container(color: Colors.white);
                  }
                }),
              ),
            ),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).viewPadding.top + 45),
        Column(
          children: [
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => SideButton(
                    activeColor: MyTheme.appolloRed,
                    disableColor: MyTheme.appolloWhite,
                    title: 'Sat 12th 2021',
                    isTap: false,
                    onTap: () {},
                  ),
                ),
              ).paddingAll(8),
            ).appolloCard(color: MyTheme.appolloDarkBlue.withAlpha(190)),
            SizedBox(height: MyTheme.cardPadding),
            InkWell(
              onTap: () {
                widget.scrollController
                    .animateTo(positions[0] - 100, duration: MyTheme.animationDuration, curve: Curves.easeIn);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: MyTheme.appolloGrey.withAlpha(80),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_downward, color: MyTheme.appolloGreen, size: 28).paddingAll(4),
              ),
            ),
          ],
        ),
        SizedBox(height: screenSize.height * 0.25),
      ],
    );
  }

  Duration _duration(DateTime time) => time.difference(DateTime.now());
}
