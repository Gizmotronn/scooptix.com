import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/main.dart';
import 'package:ticketapp/model/ticket.dart';
import 'package:ticketapp/pages/authentication/authentication_page.dart';
import 'package:ticketapp/pages/my_ticktes/bloc/my_tickets_bloc.dart';
import 'package:ticketapp/repositories/user_repository.dart';

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
          builder: (context) => AuthenticationPage(
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
                        style: MyTheme.lightTextTheme.headline5,
                      ),
                      Text(
                        "Close",
                        style: MyTheme.lightTextTheme.bodyText1.copyWith(color: MyTheme.appolloGreen),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: Tickets(bloc: bloc),
        );
      });
    });
  }
}

class Tickets extends StatelessWidget {
  final MyTicketsBloc bloc;

  const Tickets({Key key, this.bloc}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyTicketsBloc, MyTicketsState>(
      cubit: bloc,
      builder: (context, state) {
        if (state is StateTicketOverview) {
          return SingleChildScrollView(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _headerText('Tickets', color: MyTheme.appolloGreen).paddingBottom(16),
                  _tickets(context, state.tickets),
                  _headerText('Past Event Tickets', color: MyTheme.appolloOrange).paddingBottom(16),
                ],
              ).paddingHorizontal(16),
            ),
          );
        }
        return Container();
      },
    );
  }

  Widget _headerText(String text, {Color color}) {
    return AutoSizeText(text,
        style: MyTheme.lightTextTheme.headline4.copyWith(color: color, fontWeight: FontWeight.w600));
  }

  Widget _tickets(BuildContext context, List<Ticket> tickets) => Column(
        children: List.generate(
          5,
          (index) => Row(
            children: [
              Expanded(
                child: Container(
                  color: MyTheme.appolloLightCardColor,
                  height: 120,
                ),
              ),
              Container(
                color: MyTheme.appolloLightCardColor,
                height: 120,
                width: MediaQuery.of(context).size.width * 0.25,
              ).paddingLeft(2.5),
            ],
          ).paddingBottom(16),
        ),
      );
}
