import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:ticketapp/UI/widgets/appollo/appolloDivider.dart';
import 'package:ticketapp/UI/widgets/cards/tickets_card.dart';
import 'package:ticketapp/model/ticket_release.dart';
import 'package:ticketapp/pages/order_summary/order_summary_overlay.dart';
import 'package:ticketapp/utilities/format_date/full_date_time.dart';
import '../../../model/event.dart';
import '../../../UI/theme.dart';

class EventTickets extends StatefulWidget {
  final Event event;

  EventTickets({
    Key key,
    this.event,
  }) : super(key: key);

  @override
  _EventTicketsState createState() => _EventTicketsState();
}

class _EventTicketsState extends State<EventTickets> {
  final Map<TicketRelease, int> selectedTickets = {};
  final double height = 580;
  final double checkoutWidth = 305;

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
        AutoSizeText(
          'Tickets',
          style: MyTheme.textTheme.headline2.copyWith(color: MyTheme.appolloGreen, fontWeight: FontWeight.w600),
        ).paddingBottom(30),
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
                      _header(context, text: widget.event.name),
                      _subHeader(context,
                          text: "${fullDateWithYear(widget.event.date)} - ${time(widget.event.endTime)}"),
                      Expanded(
                        child: Container(
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
                                          selectedTickets
                                              .containsKey(widget.event.releaseManagers[index].getActiveRelease())) {
                                        setState(() {
                                          selectedTickets
                                              .remove(widget.event.releaseManagers[index].getActiveRelease());
                                        });
                                      } else if (q != 0) {
                                        setState(() {
                                          selectedTickets[widget.event.releaseManagers[index].getActiveRelease()] = q;
                                        });
                                      }
                                    });
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
                      color: MyTheme.appolloCardColorLight,
                    ),
                    child: OrderSummaryOverlay(
                      widget.event,
                      selectedTickets: selectedTickets,
                      maxWidth: checkoutWidth,
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
