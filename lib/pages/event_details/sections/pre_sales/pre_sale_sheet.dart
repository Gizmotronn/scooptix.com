import 'package:flutter/material.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/appollo/appollo_bottom_sheet.dart';
import 'package:ticketapp/main.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/pages/authentication/authentication_sheet_wrapper.dart';
import 'package:ticketapp/pages/event_details/sections/pre_sales/pre_sale_page.dart';
import 'package:ticketapp/repositories/user_repository.dart';

import 'bloc/pre_sale_bloc.dart';

class PreSaleSheet extends StatefulWidget {
  final PreSaleBloc? bloc;
  final Event event;
  PreSaleSheet._(this.bloc, {required this.event});

  /// Makes sure the user is logged in before opening the My Ticket Sheet
  static openPreSaleSheet(PreSaleBloc? bloc, {required Event event}) {
    if (UserRepository.instance.isLoggedIn) {
      showAppolloModalBottomSheet(
          context: WrapperPage.navigatorKey.currentContext!,
          backgroundColor: MyTheme.scoopBackgroundColorLight,
          expand: true,
          settings: RouteSettings(name: "presale_sheet"),
          builder: (context) => PreSaleSheet._(
                bloc,
                event: event,
              ));
    } else {
      showAppolloModalBottomSheet(
          context: WrapperPage.navigatorKey.currentContext!,
          backgroundColor: MyTheme.scoopBackgroundColorLight,
          expand: true,
          builder: (context) => AuthenticationPageWrapper(
                onAutoAuthenticated: (autoLoggedIn) {
                  Navigator.pop(WrapperPage.navigatorKey.currentContext!);
                  showAppolloModalBottomSheet(
                      context: WrapperPage.navigatorKey.currentContext!,
                      backgroundColor: MyTheme.scoopBackgroundColorLight,
                      expand: true,
                      settings: RouteSettings(name: "authentication_sheet"),
                      builder: (context) => PreSaleSheet._(bloc, event: event));
                },
              ));
    }
  }

  @override
  _PreSaleSheetState createState() => _PreSaleSheetState();
}

class _PreSaleSheetState extends State<PreSaleSheet> {
  late PreSaleBloc bloc;

  @override
  void initState() {
    if (widget.bloc == null) {
      bloc = PreSaleBloc();
      bloc.add(EventCheckStatus(widget.event));
    } else {
      bloc = widget.bloc!;
    }
    super.initState();
  }

  @override
  void dispose() {
    if (widget.bloc == null) {
      bloc.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: MyTheme.scoopCardColorLight,
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
                      "You're registered",
                      style: MyTheme.textTheme.headline5,
                    ),
                    Text(
                      "Done",
                      style: MyTheme.textTheme.bodyText1!.copyWith(color: MyTheme.scoopGreen),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        body: PreSalePage(
          bloc: bloc,
          event: widget.event,
        ).paddingAll(MyTheme.elementSpacing));
  }
}
