import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/appollo/appollo_progress_indicator.dart';
import 'package:ticketapp/main.dart';
import 'package:ticketapp/model/ticket.dart';
import 'package:ticketapp/pages/authentication/authentication_sheet_wrapper.dart';
import 'package:ticketapp/pages/my_ticktes/bloc/my_tickets_bloc.dart';
import 'package:ticketapp/repositories/user_repository.dart';
import 'package:ticketapp/utilities/svg/icon.dart';

import 'myticket_card.dart';

class MyTicketsSheet extends StatefulWidget {
  MyTicketsSheet._();

  /// Makes sure the user is logged in before opening the My Ticket Sheet
  static openMyTicketsSheet() {
    if (UserRepository.instance.isLoggedIn) {
      showCupertinoModalBottomSheet(
          context: WrapperPage.navigatorKey.currentContext,
          backgroundColor: MyTheme.appolloBackgroundColor,
          expand: true,
          builder: (context) => MyTicketsSheet._());
    } else {
      showCupertinoModalBottomSheet(
          context: WrapperPage.navigatorKey.currentContext,
          backgroundColor: MyTheme.appolloBackgroundColor,
          expand: true,
          builder: (context) => AuthenticationPageWrapper(
                onAutoAuthenticated: (autoLoggedIn) {
                  Navigator.pop(WrapperPage.navigatorKey.currentContext);
                  showCupertinoModalBottomSheet(
                      context: WrapperPage.navigatorKey.currentContext,
                      backgroundColor: MyTheme.appolloBackgroundColor,
                      expand: true,
                      builder: (context) => MyTicketsSheet._());
                },
              ));
    }
  }

  @override
  _MyTicketsSheetState createState() => _MyTicketsSheetState();
}

class _MyTicketsSheetState extends State<MyTicketsSheet> {
  MyTicketsBloc bloc;

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
    /*
    * To push a new page use
    *  Navigator.push(
            sheetContext,
            MaterialPageRoute(
                builder: (c) => NewPage()));
    *
    * */
    return Navigator(onGenerateRoute: (_) {
      return MaterialPageRoute(builder: (sheetContext) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: MyTheme.appolloCardColorLight,
            automaticallyImplyLeading: false,
            title: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: MyTheme.elementSpacing, vertical: MyTheme.elementSpacing),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox.shrink(),
                      Text(
                        "My Tickets",
                        style: MyTheme.textTheme.headline5,
                      ),
                      Text(
                        "Done",
                        style: MyTheme.textTheme.bodyText1.copyWith(color: MyTheme.appolloGreen),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: BlocBuilder<MyTicketsBloc, MyTicketsState>(
            cubit: bloc,
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
                              _tickets(sheetContext,
                                      tickets: state.tickets
                                          .where((ticket) =>
                                              ticket.event.date.isAfter(DateTime.now().add(Duration(hours: 8))))
                                          .toList(),
                                      isPastTicket: false)
                                  .paddingBottom(MyTheme.elementSpacing * 2),
                              _headerText('Past Event Tickets', color: MyTheme.appolloOrange)
                                  .paddingBottom(MyTheme.cardPadding),
                              _tickets(sheetContext,
                                  tickets: state.tickets
                                      .where((ticket) =>
                                          ticket.event.date.isBefore(DateTime.now().add(Duration(hours: 8))))
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
          ),
        );
      });
    });
  }

  Widget _headerText(String text, {Color color}) {
    return AutoSizeText(text, style: MyTheme.textTheme.headline4.copyWith(color: color, fontWeight: FontWeight.w600));
  }

  Widget _tickets(BuildContext sheetContext, {List<Ticket> tickets, bool isPastTicket}) => ListView.builder(
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
                style: Theme.of(context).textTheme.subtitle1.copyWith(fontWeight: FontWeight.w300),
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
