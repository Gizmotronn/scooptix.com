import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/appollo/appollo_progress_indicator.dart';
import 'package:ticketapp/model/ticket.dart';
import 'package:ticketapp/utilities/svg/icon.dart';

import 'bloc/my_tickets_bloc.dart';
import 'myticket_card.dart';

class MyTicketsPage extends StatefulWidget {
  final BuildContext parentContext;

  const MyTicketsPage({Key? key, required this.parentContext}) : super(key: key);
  @override
  _MyTicketsPageState createState() => _MyTicketsPageState();
}

class _MyTicketsPageState extends State<MyTicketsPage> {
  late MyTicketsBloc bloc;

  @override
  void initState() {
    bloc = MyTicketsBloc();
    bloc.add(EventLoadMyTickets());
    super.initState();
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyTicketsBloc, MyTicketsState>(
      bloc: bloc,
      builder: (context, state) {
        if (state is StateTicketOverview) {
          return state.tickets.isEmpty
              ? _noTicket(context)
              : SingleChildScrollView(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _headerText('Tickets', color: MyTheme.appolloGreen)
                            .paddingBottom(MyTheme.cardPadding)
                            .paddingTop(MyTheme.elementSpacing),
                        _tickets(widget.parentContext,
                                tickets: state.tickets
                                    .where(
                                        (ticket) => ticket.event!.date.isAfter(DateTime.now().add(Duration(hours: 8))))
                                    .toList(),
                                isPastTicket: false)
                            .paddingBottom(MyTheme.elementSpacing * 2),
                        _headerText('Past Event Tickets', color: MyTheme.appolloOrange)
                            .paddingBottom(MyTheme.cardPadding),
                        _tickets(widget.parentContext,
                            tickets: state.tickets
                                .where((ticket) => ticket.event!.date.isBefore(DateTime.now().add(Duration(hours: 8))))
                                .toList(),
                            isPastTicket: true),
                      ],
                    ).paddingHorizontal(MyTheme.elementSpacing),
                  ),
                );
        } else {
          return Center(
            child: AppolloProgressIndicator(),
          );
        }
      },
    );
  }

  Widget _headerText(String text, {required Color color}) {
    return AutoSizeText(text, style: MyTheme.textTheme.headline4!.copyWith(color: color, fontWeight: FontWeight.w600));
  }

  Widget _tickets(BuildContext sheetContext, {required List<Ticket> tickets, required bool isPastTicket}) =>
      ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: tickets.length,
        itemBuilder: (c, index) => MyTicketCard(
          sheetContext: sheetContext,
          ticket: tickets[index],
          isPastTicket: isPastTicket,
        ).paddingBottom(MyTheme.elementSpacing),
      );

  Widget _noTicket(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _headerText('Tickets', color: MyTheme.appolloGreen).paddingBottom(MyTheme.cardPadding).paddingTop(16),
              AutoSizeText(
                "You do not currently have a ticket to an event.\n\nOnce you purchase a ticket it will be displayed here so it's always easy to find.",
                style: Theme.of(context).textTheme.subtitle1!.copyWith(fontWeight: FontWeight.w300),
              ),
            ],
          ),
          Align(
              alignment: Alignment.center,
              child: SvgPicture.asset(
                AppolloSvgIcon.tickets,
                width: MediaQuery.of(context).size.height * 0.3,
              )).paddingAll(MyTheme.elementSpacing),
          SizedBox.shrink(),
        ],
      ).paddingHorizontal(MyTheme.elementSpacing);
}
