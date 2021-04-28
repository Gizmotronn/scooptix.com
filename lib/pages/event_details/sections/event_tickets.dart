import 'package:flutter/material.dart';
import 'package:ticketapp/UI/event_details/widget/event_title.dart';
import 'package:ticketapp/UI/widgets/appollo/appolloDivider.dart';
import 'package:ticketapp/pages/ticket/ticket_page.dart';
import '../../../model/event.dart';
import '../../../UI/theme.dart';

class EventTickets extends StatelessWidget {
  const EventTickets({
    Key key,
    this.event,
    this.linkType,
  }) : super(key: key);
  final Event event;

  final linkType;
  final double height = 500;
  final double checkoutWidth = 280;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        EventDetailTitle('Tickets').paddingBottom(30),
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: height, minWidth: 500, maxHeight: height, maxWidth: 800),
          child: Stack(
            children: [
              Container(
                color: MyTheme.appolloCardColor,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: event.releaseManagers.length,
                  itemBuilder: (c, index) {
                    if (event.releaseManagers[index].getActiveRelease() != null) {
                      return Column(
                        children: [
                          // Ticket name
                          Text(event.releaseManagers[index].name),
                          // Ticket price
                          Text("\$${(event.releaseManagers[index].getActiveRelease().price / 100).toStringAsFixed(2)}"),
                          // Ticket full price if available
                          if (event.releaseManagers[index].getFullPrice() >
                              event.releaseManagers[index].getActiveRelease().price)
                            Text(
                                "Full Price\$${(event.releaseManagers[index].getFullPrice() / 100).toStringAsFixed(2)}"),
                          Text(event.releaseManagers[index].getActiveRelease().includedPerks[0]),
                          Text(event.releaseManagers[index].getActiveRelease().excludedPerks[0]),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          Text(event.releaseManagers[index].name),
                          Text("Unavailable"),
                        ],
                      );
                    }
                  },
                ),
              ),
              Positioned(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  width: 250,
                  child: Container(
                      child: TicketPage(
                    linkType,
                    forwardToPayment: false,
                  )).appolloCard()),
            ],
          ),
        ).paddingBottom(MyTheme.elementSpacing),
        AppolloDivider(),
      ],
    ));
  }
}
