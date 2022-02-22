import 'package:flutter/material.dart';
import 'package:ticketapp/UI/widgets/appollo/appollo_divider.dart';
import 'package:ticketapp/model/organizer.dart';
import 'package:ticketapp/pages/app_bar.dart';
import 'package:ticketapp/pages/event_details/birthday_list/make_booking.dart';
import 'package:ticketapp/pages/event_details/mobile/event_info.dart';
import 'package:ticketapp/pages/event_details/sections/event_description.dart';
import 'package:ticketapp/pages/event_details/sections/event_gallery.dart';
import 'package:ticketapp/pages/event_details/sections/pre_sales/pre_sale_registration_page.dart';
import 'package:ticketapp/pages/event_details/sections/similar_other_events.dart';
import 'package:ticketapp/pages/events_overview/bloc/events_overview_bloc.dart';
import '../../../UI/theme.dart';
import '../../../model/event.dart';
import 'event_tickets_mobile.dart';

class EventDataMobile extends StatefulWidget {
  final Event event;
  final Organizer organizer;
  final ScrollController scrollController;
  final EventsOverviewBloc bloc;
  EventDataMobile(
      {Key? key, required this.event, required this.organizer, required this.scrollController, required this.bloc})
      : super(key: key);

  @override
  _EventDataMobileState createState() => _EventDataMobileState();
}

class _EventDataMobileState extends State<EventDataMobile> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return _mainBody(context, screenSize);
  }

  Widget _mainBody(BuildContext context, Size screenSize) {
    return Container(
      child: SingleChildScrollView(
        controller: widget.scrollController,
        child: Column(
          children: [
            AppolloAppBar(
              backgroundColor: MyTheme.scoopBackgroundColor,
            ).paddingBottom(MyTheme.elementSpacing),
            _buildEventDetailWithCountdown(context).paddingHorizontal(MyTheme.elementSpacing),
            EventDescription(event: widget.event).paddingHorizontal(MyTheme.elementSpacing),
            if (widget.event.preSaleEnabled)
              PreSaleRegistrationPage(
                event: widget.event,
                scrollController: widget.scrollController,
              ),
            EventTicketsMobile(
              event: widget.event,
              scrollController: widget.scrollController,
            ),
            if (widget.event.allowsBirthdaySignUps) MakeBooking(event: widget.event),
            EventGallary(event: widget.event)
                .paddingBottom(MyTheme.elementSpacing)
                .paddingHorizontal(MyTheme.elementSpacing),
            SimilarOtherEvents(event: widget.event)
                .paddingBottom(MyTheme.elementSpacing * 3)
                .paddingHorizontal(MyTheme.elementSpacing),
          ],
        ).paddingBottom(MyTheme.elementSpacing),
      ),
    ).appolloBlurCard(color: MyTheme.scoopBackgroundColorLight, borderRadius: BorderRadius.circular(0));
  }

  Widget _buildEventDetailWithCountdown(BuildContext context) {
    return Container(
      child: Column(
        children: [
          EventInfoMobile(
            event: widget.event,
            organizer: widget.organizer,
          ),
          AppolloDivider(),
        ],
      ),
    );
  }
}
