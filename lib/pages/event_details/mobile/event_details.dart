import 'package:flutter/material.dart';
import 'package:ticketapp/UI/event_details/widget/make_booking.dart';
import 'package:ticketapp/UI/widgets/appollo/appolloDivider.dart';
import 'package:ticketapp/model/organizer.dart';
import 'package:ticketapp/pages/event_details/mobile/event_info.dart';
import 'package:ticketapp/pages/event_details/sections/event_description.dart';
import 'package:ticketapp/pages/event_details/sections/event_gallery.dart';
import 'package:ticketapp/pages/event_details/sections/pre_sales/pre_sale_registration.dart';
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
  final Function physics;
  EventDataMobile({Key key, this.event, this.organizer, this.scrollController, this.bloc, this.physics})
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
      child: Column(
        children: [
          _buildEventDetailWithCountdown(context).paddingHorizontal(MyTheme.elementSpacing),
          EventDescription(event: widget.event).paddingHorizontal(MyTheme.elementSpacing),
          PreSaleRegistration(event: widget.event).paddingHorizontal(MyTheme.elementSpacing),
          EventTicketsMobile(
            event: widget.event,
            scrollController: widget.scrollController,
          ),
          MakeBooking(event: widget.event),
          EventGallary(event: widget.event)
              .paddingBottom(MyTheme.elementSpacing)
              .paddingHorizontal(MyTheme.elementSpacing),
          SimilarOtherEvents(event: widget.event)
              .paddingBottom(MyTheme.elementSpacing * 2)
              .paddingHorizontal(MyTheme.elementSpacing),
        ],
      ).paddingVertical(MyTheme.elementSpacing),
    ).appolloCard(color: MyTheme.appolloBackgroundColorLight);
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
