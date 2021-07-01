import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/model/discount.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/model/ticket_release.dart';
import 'package:ticketapp/pages/payment/payment_page.dart';
import 'package:ticketapp/utilities/svg/icon.dart';

class PaymentSheetWrapper extends StatefulWidget {
  final Event event;
  final Map<TicketRelease, int> selectedTickets;
  final Discount discount;
  final double maxHeight;
  final BuildContext parentContext;

  const PaymentSheetWrapper(
      {Key key, this.event, this.selectedTickets, this.discount, this.maxHeight, this.parentContext})
      : super(key: key);

  @override
  _PaymentSheetWrapperState createState() => _PaymentSheetWrapperState();
}

class _PaymentSheetWrapperState extends State<PaymentSheetWrapper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: MyTheme.appolloCardColorLight,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: SvgPicture.asset(
            AppolloSvgIcon.arrowBackOutline,
            color: MyTheme.appolloWhite,
            height: 36,
            width: 36,
            fit: BoxFit.scaleDown,
          ),
        ),
        centerTitle: true,
        title: Container(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: MyTheme.elementSpacing, vertical: MyTheme.elementSpacing),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Order Summary",
                        style: MyTheme.textTheme.headline5,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(widget.parentContext);
                      },
                      child: Text(
                        "Close",
                        style: MyTheme.textTheme.bodyText1.copyWith(color: MyTheme.appolloGreen),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: MyTheme.elementSpacing),
        child: PaymentPage(
          widget.event,
          discount: widget.discount,
          selectedTickets: widget.selectedTickets,
          maxHeight: MediaQuery.of(context).size.height,
          parentContext: widget.parentContext,
        ),
      ),
    );
  }
}
