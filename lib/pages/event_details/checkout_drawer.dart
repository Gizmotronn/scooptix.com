import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/model/discount.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/model/link_type/memberInvite.dart';
import 'package:ticketapp/model/ticket_release.dart';
import 'package:ticketapp/pages/payment/payment_page.dart';
import 'package:ticketapp/repositories/user_repository.dart';

import '../../main.dart';
import '../authentication/authentication_drawer.dart';

/// In the desktop view, most of the functionality is displayed in the end drawer.
class CheckoutDrawer extends StatefulWidget {
  final Event event;
  final Map<TicketRelease, int> selectedTickets;
  final Discount? discount;

  const CheckoutDrawer({Key? key, required this.event, required this.selectedTickets, required this.discount})
      : super(key: key);

  @override
  _CheckoutDrawerState createState() => _CheckoutDrawerState();
}

class _CheckoutDrawerState extends State<CheckoutDrawer> {
  @override
  void initState() {
    if (!UserRepository.instance.isLoggedIn) {
      Future.delayed(Duration(milliseconds: 1)).then((_) {
        WrapperPage.endDrawer.value = AuthenticationDrawer();
        UserRepository.instance.currentUserNotifier.addListener(_tryOpenCheckoutDrawer());
      });
    }
    super.initState();
  }

  VoidCallback _tryOpenCheckoutDrawer() {
    return () {
      if (UserRepository.instance.isLoggedIn) {
        WrapperPage.endDrawer.value = CheckoutDrawer(
          event: widget.event,
          discount: widget.discount,
          selectedTickets: widget.selectedTickets,
        );
        WrapperPage.mainScaffold.currentState!.openEndDrawer();
      }
      UserRepository.instance.currentUserNotifier.removeListener(_tryOpenCheckoutDrawer());
    };
  }

  @override
  Widget build(BuildContext context) {
    if (!UserRepository.instance.isLoggedIn) {
      return Center(child: Text("Please login first. Forwarding you now ..."));
    }
    Size screenSize = MediaQuery.of(context).size;
    return Container(
      width: MyTheme.drawerSize,
      height: screenSize.height,
      decoration: ShapeDecoration(
          color: MyTheme.scoopBackgroundColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)))),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.close,
                size: 34,
                color: MyTheme.scoopRed,
              ),
            ),
          ).paddingRight(16).paddingTop(8),
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: MyTheme.cardPadding),
              constraints: BoxConstraints(minHeight: screenSize.height * 0.9),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Order Confirmation", style: MyTheme.textTheme.headline2)
                          .paddingBottom(MyTheme.elementSpacing),
                      Text(
                        widget.event.name,
                        style: MyTheme.textTheme.headline4!.copyWith(color: MyTheme.scoopGreen),
                      ).paddingBottom(MyTheme.elementSpacing),
                      SizedBox(
                        width: MyTheme.drawerSize,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Date:",
                                  style: MyTheme.textTheme.bodyText1,
                                ).paddingBottom(8),
                                Text(
                                  "Duration:",
                                  style: MyTheme.textTheme.bodyText1,
                                ).paddingBottom(8),
                                Text(
                                  "Location:",
                                  style: MyTheme.textTheme.bodyText1,
                                ),
                              ],
                            ),
                            SizedBox(
                              width: MyTheme.elementSpacing,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  AutoSizeText(
                                    DateFormat.yMMMMd().format(widget.event.date),
                                    style: MyTheme.textTheme.bodyText2,
                                  ).paddingBottom(8),
                                  if (widget.event.endTime != null)
                                    AutoSizeText(
                                      "${DateFormat.jm().format(widget.event.date)} - ${DateFormat.jm().format(widget.event.endTime!)} (${widget.event.endTime!.difference(widget.event.date).inHours} Hours)",
                                      style: MyTheme.textTheme.bodyText2,
                                    ).paddingBottom(8),
                                  if (widget.event.endTime == null)
                                    AutoSizeText(
                                      "${DateFormat.jm().format(widget.event.date)} ",
                                      style: MyTheme.textTheme.bodyText2,
                                    ).paddingBottom(8),
                                  AutoSizeText(
                                    widget.event.address == "" ? widget.event.venueName : widget.event.address,
                                    style: MyTheme.textTheme.bodyText2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ).paddingBottom(MyTheme.elementSpacing),
                      widget.event is MemberInvite &&
                              (widget.event as MemberInvite).promoter!.docId ==
                                  UserRepository.instance.currentUser()!.firebaseUserID
                          ? Center(
                              child:
                                  Text("You can't invite yourself to this event", style: MyTheme.textTheme.bodyText2))
                          : PaymentPage(
                              widget.event,
                              maxHeight: screenSize.height - 302,
                              selectedTickets: widget.selectedTickets,
                              discount: widget.discount,
                            ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Events Powered By", style: MyTheme.textTheme.bodyText2!.copyWith(color: Colors.grey))
                          .paddingRight(4)
                          .paddingBottom(4),
                      Text("ScoopTix",
                          style: MyTheme.textTheme.subtitle1!.copyWith(
                            color: MyTheme.scoopPurple,
                            fontSize: 18,
                          ))
                    ],
                  ).paddingBottom(MyTheme.elementSpacing).paddingTop(MyTheme.elementSpacing),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
