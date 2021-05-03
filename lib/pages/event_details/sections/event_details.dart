import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ticketapp/UI/event_overview/event_overview_home.dart';
import 'package:ticketapp/UI/widgets/appollo/appolloDivider.dart';
import 'package:ticketapp/UI/widgets/buttons/apollo_button.dart';
import 'package:ticketapp/UI/widgets/buttons/card_button.dart';
import 'package:ticketapp/UI/widgets/cards/appollo_bg_card.dart';
import 'package:ticketapp/model/link_type/overview.dart';
import 'package:ticketapp/model/organizer.dart';
import 'package:ticketapp/pages/event_details/event_detail_page.dart';
import 'package:ticketapp/pages/event_details/sections/pre_sales/pre_sale_registration.dart';
import 'package:ticketapp/pages/events_overview/bloc/events_overview_bloc.dart';
import 'package:ticketapp/repositories/events_repository.dart';
import '../../../UI/theme.dart';
import '../../../UI/widgets/buttons/side_buttons.dart';
import '../../../model/event.dart';
import '../../../UI/event_details/widget/counter.dart';
import 'detail_with_button.dart';
import '../../../UI/event_details/widget/event_title.dart';
import '../../../UI/event_details/widget/make_booking.dart';
import 'event_description.dart';
import 'event_gallery.dart';
import 'event_tickets.dart';
import 'similar_other_events.dart';

class EventDetailInfo extends StatefulWidget {
  final Event event;
  final Organizer organizer;
  final ScrollController scrollController;
  final EventsOverviewBloc bloc;
  const EventDetailInfo({Key key, this.event, this.organizer, this.scrollController, this.bloc}) : super(key: key);

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

  double previousScrollPosition = 0.0;

  List<double> positions = [];
  @override
  void initState() {
    super.initState();
    positions.add(0.0);
    _tabButtons.forEach((element) {
      positions.add(0.0);
    });

    Future.delayed(Duration(milliseconds: 1)).then((_) {
      EventDetailPage.fab.value = InkWell(
        onTap: () {
          widget.scrollController
              .animateTo(positions[0] - 90, duration: MyTheme.animationDuration, curve: Curves.easeIn);
        },
        child: Container(
          decoration: BoxDecoration(
            color: MyTheme.appolloGrey.withAlpha(80),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.arrow_downward, color: MyTheme.appolloGreen, size: 28).paddingAll(4),
        ),
      );
    });

    widget.scrollController.addListener(() {
      if (widget.scrollController.offset > 0) {
        if (EventDetailPage.fab.value != null) {
          EventDetailPage.fab.value = null;
        }
      } else {
        EventDetailPage.fab.value = InkWell(
          onTap: () {
            widget.scrollController
                .animateTo(positions[0] - 90, duration: MyTheme.animationDuration, curve: Curves.easeIn);
          },
          child: Container(
            decoration: BoxDecoration(
              color: MyTheme.appolloGrey.withAlpha(80),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_downward, color: MyTheme.appolloGreen, size: 28).paddingAll(4),
          ),
        );
      }
      if (widget.scrollController.offset < positions[0] - 90) {
        if (previousScrollPosition > widget.scrollController.offset) {
          widget.scrollController.jumpTo(0);
        } else {
          widget.scrollController.jumpTo(positions[0] - 90);
        }
      }

      previousScrollPosition = widget.scrollController.offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Column(
      children: [
        _eventImageDays(context, screenSize),
        _mainBody(context, screenSize).paddingBottom(MyTheme.elementSpacing * 2),
        SimilarOtherEvents(event: widget.event).paddingBottom(80),
      ],
    );
  }

  Widget _mainBody(BuildContext context, Size screenSize) {
    return Container(
      child: Column(
        children: [
          BoxOffset(
            boxOffset: (offset) => setState(() => positions[0] = offset.dy),
            child: _buildEventDetailWithCountdown(context),
          ),
          BoxOffset(
            boxOffset: (offset) => setState(() => positions[1] = offset.dy),
            child: EventDescription(event: widget.event),
          ),
          BoxOffset(
            boxOffset: (offset) => setState(() => positions[2] = offset.dy),
            child: PreSaleRegistration(event: widget.event),
          ),
          BoxOffset(
            boxOffset: (offset) => setState(() => positions[3] = offset.dy),
            child: EventTickets(
              event: widget.event,
              linkType: OverviewLinkType(widget.event),
            ),
          ),
          BoxOffset(
            boxOffset: (offset) => setState(() => positions[4] = offset.dy),
            child: MakeBooking(event: widget.event),
          ),
          BoxOffset(
            boxOffset: (offset) => setState(() => positions[5] = offset.dy),
            child: EventGallary(event: widget.event),
          ),
        ],
      ).paddingAll(MyTheme.cardPadding),
    ).appolloCard(color: MyTheme.appolloBackgroundColor2);
  }

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
                      .animateTo(positions[index + 1] - 100, curve: Curves.linear, duration: MyTheme.animationDuration);
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
                style: Theme.of(context).textTheme.button.copyWith(color: MyTheme.appolloBackgroundColor),
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
    return Countdown(
      width: 432,
      duration: widget.event.date.difference(DateTime.now()),
    );
  }

  Widget _eventImageDays(BuildContext context, Size screenSize) {
    positions[0] = MediaQuery.of(context).size.height < 756 ? 756 : MediaQuery.of(context).size.height;
    return SizedBox(
      height: MediaQuery.of(context).size.height < 756 ? 756 : MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: MyTheme.maxWidth,
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
          ).paddingTop(10),
          SizedBox(height: MyTheme.elementSpacing * 2),
          _buildRecurringEventDates(),
        ],
      ),
    );
  }

  Widget _buildRecurringEventDates() {
    if (widget.event.occurrence == EventOccurrence.Single) {
      return SizedBox.shrink();
    } else {
      List<Event> recurringEvents = EventsRepository.instance.getRecurringEvents(widget.event.recurringEventId);
      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(
            recurringEvents.length,
            (index) => SideButton(
              activeColor: MyTheme.appolloRed,
              disableColor: MyTheme.appolloWhite,
              title: DateFormat('EEE dd. MMM').format(recurringEvents[index].date),
              highlight: recurringEvents[index].docID == widget.event.docID,
              onTap: () {
                widget.bloc.add(LoadEventDetailEvent(recurringEvents[index].docID));
              },
            ),
          ),
        ).paddingAll(8),
      ).appolloCard(color: MyTheme.appolloBackgroundColor.withAlpha(190)).paddingBottom(MyTheme.cardPadding);
    }
  }
}
