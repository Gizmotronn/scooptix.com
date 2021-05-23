import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ticketapp/UI/event_overview/event_overview_home.dart';
import 'package:ticketapp/UI/widgets/appollo/appolloDivider.dart';
import 'package:ticketapp/UI/widgets/buttons/card_button.dart';
import 'package:ticketapp/UI/widgets/cards/appollo_bg_card.dart';
import 'package:ticketapp/model/organizer.dart';
import 'package:ticketapp/pages/event_details/event_detail_page.dart';
import 'package:ticketapp/pages/event_details/sections/pre_sales/pre_sale_registration_page.dart';
import 'package:ticketapp/pages/events_overview/bloc/events_overview_bloc.dart';
import 'package:ticketapp/repositories/events_repository.dart';
import '../../../UI/theme.dart';
import '../../../UI/widgets/buttons/side_buttons.dart';
import '../../../model/event.dart';
import 'detail_with_button.dart';
import '../../../UI/event_details/widget/make_booking.dart';
import 'event_description.dart';
import 'event_gallery.dart';
import 'event_nav_bar.dart';
import 'event_tickets.dart';
import 'similar_other_events.dart';

class EventData extends StatefulWidget {
  final Event event;
  final Organizer organizer;
  final ScrollController scrollController;
  final EventsOverviewBloc bloc;
  final Function physics;
  EventData({Key key, this.event, this.organizer, this.scrollController, this.bloc, this.physics}) : super(key: key);

  @override
  _EventDataState createState() => _EventDataState();
}

class _EventDataState extends State<EventData> {
  List<Menu> _tabButtons = [];

  double previousScrollPosition = 0.0;

  Map<int, double> positions = {};
  @override
  void initState() {
    super.initState();
    _tabButtons = [
      Menu('Detail', false, id: 1),
    ];

    if (widget.event.preSaleAvailable) {
      _tabButtons.add(Menu('Pre-Sale', false, id: 2));
    }
    if (widget.event.releaseManagers.isNotEmpty) {
      _tabButtons.add(Menu('Tickets', false, id: 3));
    }
    if (widget.event.allowsBirthdaySignUps) {
      _tabButtons.add(Menu('Make a Booking', false, id: 4));
    }
    if (widget.event.images.isNotEmpty) {
      _tabButtons.add(Menu('Location', false, id: 5));
    }

    positions[0] = 0.0;
    _tabButtons.forEach((element) {
      positions[element.id] = 0.0;
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

    // Starting to scroll from the top of the page starts an automatic scroll to the event details.
    // Works the same in return when scrolling above the event details.
    bool scrolling = false;
    widget.scrollController.addListener(() async {
      if (scrolling) {
        return;
      }
      if (widget.scrollController.offset > 0) {
        if (EventDetailPage.fab.value != null) {
          EventDetailPage.fab.value = null;
        }
      } else {
        EventDetailPage.fab.value = InkWell(
          onTap: () async {
            scrolling = true;
            await widget.scrollController
                .animateTo(positions[0] - 90, duration: MyTheme.animationDuration, curve: Curves.easeIn);
            if (EventDetailPage.fab.value != null) {
              EventDetailPage.fab.value = null;
            }
            scrolling = false;
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
      /* if (widget.scrollController.offset < positions[0] - 90) {
        scrolling = true;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          print(widget.scrollController.offset);
          if (previousScrollPosition > widget.scrollController.offset) {
            await widget.scrollController.animateTo(0, duration: MyTheme.animationDuration, curve: Curves.easeIn);
            previousScrollPosition = widget.scrollController.offset;
          } else {
            await widget.scrollController
                .animateTo(positions[0] - 90, duration: MyTheme.animationDuration, curve: Curves.easeIn);
            previousScrollPosition = widget.scrollController.offset;
          }
          scrolling = false;
        });
      }*/
      if (!scrolling) {
        previousScrollPosition = widget.scrollController.offset;
      }
    });
  }

  Widget _buildNavBar(Event event) {
    if (event.preSaleEnabled &&
        event.preSale.registrationStartDate.isBefore(DateTime.now()) &&
        event.preSale.registrationEndDate.isAfter(DateTime.now())) {
      return EventDetailNavbar(
        imageURL: event.coverImageURL,
        mainText: "Register for Pre-Sale",
        buttonText: "Register",
        scrollController: widget.scrollController,
        offset: positions[2] - 90,
      );
    } else {
      return EventDetailNavbar(
        imageURL: event.coverImageURL,
        mainText: widget.event.name,
        buttonText: "Get Tickets",
        scrollController: widget.scrollController,
        offset: positions[3] - 90,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Stack(
      children: [
        SingleChildScrollView(
          controller: widget.scrollController,
          padding: EdgeInsets.symmetric(horizontal: (MediaQuery.of(context).size.width - MyTheme.maxWidth) / 2),
          child: Column(
            children: [
              _eventImageDays(context, screenSize),
              _mainBody(context, screenSize).paddingBottom(MyTheme.elementSpacing * 2),
              SimilarOtherEvents(event: widget.event).paddingBottom(80),
            ],
          ),
        ),
        Positioned(bottom: 0, left: 0, right: 0, child: _buildNavBar(widget.event)),
      ],
    );
  }

  Widget _mainBody(BuildContext context, Size screenSize) {
    return Container(
      child: Column(
        children: [
          if (positions.containsKey(0))
            BoxOffset(
              boxOffset: (offset) => setState(() => positions[0] = offset.dy),
              child: _buildEventDetailWithCountdown(context),
            ),
          if (positions.containsKey(1))
            BoxOffset(
              boxOffset: (offset) => setState(() => positions[1] = offset.dy),
              child: EventDescription(event: widget.event),
            ),
          if (positions.containsKey(2))
            BoxOffset(
              boxOffset: (offset) => setState(() => positions[2] = offset.dy),
              child: PreSaleRegistrationPage(event: widget.event),
            ),
          if (positions.containsKey(3))
            BoxOffset(
              boxOffset: (offset) => setState(() => positions[3] = offset.dy),
              child: EventTickets(
                event: widget.event,
              ),
            ),
          if (positions.containsKey(4))
            BoxOffset(
              boxOffset: (offset) => setState(() => positions[4] = offset.dy),
              child: MakeBooking(event: widget.event),
            ),
          if (positions.containsKey(5))
            BoxOffset(
              boxOffset: (offset) => setState(() => positions[5] = offset.dy),
              child: EventGallary(event: widget.event),
            ),
        ],
      ).paddingAll(MyTheme.cardPadding),
    ).appolloBlurCard(color: MyTheme.appolloBackgroundColorLight);
  }

  Widget _buildEventDetailWithCountdown(BuildContext context) {
    return Container(
      child: Column(
        children: [
          EventInfo(
            event: widget.event,
            organizer: widget.organizer,
            buttons: List.generate(
              _tabButtons.length,
              (index) => CardButton(
                title: _tabButtons[index].title,
                width: 175,
                height: 40,
                borderRadius: BorderRadius.circular(5),
                activeColor: MyTheme.appolloGreen,
                deactiveColor: MyTheme.appolloGrey.withAlpha(140),
                activeColorText: MyTheme.appolloWhite,
                deactiveColorText: MyTheme.appolloGreen,
                onTap: () async {
                  await widget.scrollController.animateTo(positions[_tabButtons[index].id] - 100,
                      curve: Curves.linear, duration: MyTheme.animationDuration);
                },
              ),
            ),
          ),
          AppolloDivider(),
        ],
      ),
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
      ).appolloBlurCard(color: MyTheme.appolloBackgroundColor.withAlpha(190)).paddingBottom(MyTheme.cardPadding);
    }
  }
}
