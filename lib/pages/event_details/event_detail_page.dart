import 'package:flutter/material.dart';
import 'package:ticketapp/UI/event_details/eventInfo.dart';
import 'package:ticketapp/UI/widgets/backgrounds/events_details_background.dart';
import 'package:ticketapp/model/link_type/link_type.dart';
import 'package:ticketapp/model/link_type/overview.dart';
import 'package:ticketapp/pages/error_page.dart';
import 'package:ticketapp/repositories/events_repository.dart';
import '../../UI/theme.dart';

class EventDetail extends StatefulWidget {
  static const String routeName = '/event';
  final String id;

  const EventDetail({Key key, this.id}) : super(key: key);

  @override
  _EventDetailState createState() => _EventDetailState();
}

class _EventDetailState extends State<EventDetail> {
  bool isLoading = false;
  LinkType linkType;

  @override
  void initState() {
    getEvent();
    super.initState();
  }

  getEvent() async {
    setState(() {
      isLoading = true;
    });
    final event = await EventsRepository.instance.loadEventById(widget.id);
    final overviewLinkType = OverviewLinkType(event);
    setState(() {
      linkType = overviewLinkType;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(builder: (context) {
        if (widget.id == null || widget.id.trim() == '') {
          return ErrorPage('Event Not Found');
        }
        return isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Stack(
                children: [
                  EventDetailBackground(
                      coverImageURL: linkType.event.coverImageURL),
                  Container(
                    child: EventInfoWidget(Axis.vertical, linkType),
                  ).appolloCard.paddingBottom(8),
                ],
              );
      }),
    );
  }
}
