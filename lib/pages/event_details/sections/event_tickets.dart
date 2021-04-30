import 'package:flutter/material.dart';
import 'package:ticketapp/UI/event_details/widget/event_title.dart';
import 'package:ticketapp/UI/widgets/appollo/appolloDivider.dart';
import 'package:ticketapp/UI/widgets/cards/tickets_card.dart';
import 'package:ticketapp/model/link_type/link_type.dart';
import 'package:ticketapp/pages/ticket/ticket_page.dart';
import 'package:ticketapp/utilities/format_date/full_date_time.dart';
import '../../../model/event.dart';
import '../../../UI/theme.dart';

class EventTickets extends StatelessWidget {
  final Event event;
  final LinkType linkType;

  EventTickets({
    Key key,
    this.event,
    this.linkType,
  }) : super(key: key);
  final double height = 500;
  final double checkoutWidth = 280;

  final List<Color> ticketColor = [
    MyTheme.appolloGreen,
    MyTheme.appolloOrange,
    MyTheme.appolloYellow,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        EventDetailTitle('Tickets').paddingBottom(30),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Container(
            constraints: BoxConstraints(minHeight: height, minWidth: 500, maxHeight: height, maxWidth: 800),
            decoration: BoxDecoration(),
            child: Row(children: [
              Expanded(
                flex: 70,
                child: Container(
                  color: MyTheme.appolloBackgroundColor,
                  child: Column(
                    children: [
                      _header(context, text: event.name),
                      _subHeader(context, text: "${fullDateWithYear(event.date)} - ${time(event.endTime)}"),
                      Expanded(
                        child: Container(
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: event.releaseManagers.length,
                              itemBuilder: (c, index) {
                                final Color color = ticketColor[index % ticketColor.length];
                                return TicketCard(release: event.releaseManagers[index], color: color);
                              }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 30,
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(topRight: Radius.circular(5), bottomRight: Radius.circular(5)),
                      color: MyTheme.appolloCardColor2,
                    ),
                    child: TicketPage(
                      linkType,
                      forwardToPayment: false,
                    ).paddingAll(16)),
              ),
            ]),
          ),
        ),
        AppolloDivider(),
      ],
    ));
  }

  Widget _header(BuildContext context, {String text}) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(5)),
        color: MyTheme.appolloPurple,
      ),
      child: Center(
        child: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .headline4
              .copyWith(fontWeight: FontWeight.w500, color: MyTheme.appolloBackgroundColor),
        ).paddingVertical(8),
      ),
    );
  }

  Widget _subHeader(BuildContext context, {String text}) {
    return Center(
      child: Text(
        text,
        style: Theme.of(context).textTheme.headline6.copyWith(fontWeight: FontWeight.w400, color: MyTheme.appolloWhite),
      ).paddingBottom(MyTheme.elementSpacing).paddingTop(8),
    );
  }
}
