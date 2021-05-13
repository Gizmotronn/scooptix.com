import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:ticketapp/UI/widgets/appollo/appolloDivider.dart';
import 'package:ticketapp/UI/widgets/cards/tickets_card.dart';
import 'package:ticketapp/model/link_type/link_type.dart';
import 'package:ticketapp/model/ticket_release.dart';
import 'package:ticketapp/pages/ticket/order_summary_sheet.dart';
import '../../../model/event.dart';
import '../../../UI/theme.dart';

class EventTicketsMobile extends StatefulWidget {
  final Event event;
  final LinkType linkType;

  EventTicketsMobile({
    Key key,
    this.event,
    this.linkType,
  }) : super(key: key);

  @override
  _EventTicketsMobileState createState() => _EventTicketsMobileState();
}

class _EventTicketsMobileState extends State<EventTicketsMobile> {
  final Map<TicketRelease, int> selectedTickets = {};
  final double height = 580;

  final List<Color> ticketColor = [
    MyTheme.appolloGreen,
    MyTheme.appolloOrange,
    MyTheme.appolloYellow,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AutoSizeText(
          'Tickets',
          style: MyTheme.lightTextTheme.headline2.copyWith(color: MyTheme.appolloGreen, fontWeight: FontWeight.w600),
        ).paddingBottom(MyTheme.elementSpacing),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 500,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(right: 8),
              itemCount: widget.event.releaseManagers.length,
              itemBuilder: (c, index) {
                final Color color = ticketColor[index % ticketColor.length];
                return TicketCard(
                    release: widget.event.releaseManagers[index],
                    color: color,
                    onQuantityChanged: (q) {
                      if (q == 0 &&
                          selectedTickets.containsKey(widget.event.releaseManagers[index].getActiveRelease())) {
                        setState(() {
                          selectedTickets.remove(widget.event.releaseManagers[index].getActiveRelease());
                        });
                      } else if (q != 0) {
                        setState(() {
                          selectedTickets[widget.event.releaseManagers[index].getActiveRelease()] = q;
                        });
                      }
                      if (selectedTickets.isNotEmpty) {
                        showBottomSheet(
                            context: context,
                            builder: (c) => OrderSummarySheet(
                                  selectedTickets: selectedTickets,
                                  linkType: widget.linkType,
                                  collapsed: true,
                                ));
                      }
                    });
              }),
        ),
        AppolloDivider(),
      ],
    );
  }
}
