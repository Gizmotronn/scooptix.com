import 'package:flutter/material.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/model/discount.dart';
import 'package:ticketapp/model/link_type/link_type.dart';
import 'package:ticketapp/model/ticket_release.dart';
import 'package:ticketapp/pages/payment/payment_page.dart';

class PaymentSheetWrapper extends StatefulWidget {
  final LinkType linkType;
  final Map<TicketRelease, int> selectedTickets;
  final Discount discount;
  final double maxHeight;
  final BuildContext parentContext;

  const PaymentSheetWrapper(
      {Key key, this.linkType, this.selectedTickets, this.discount, this.maxHeight, this.parentContext})
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
        backgroundColor: MyTheme.appolloCardColor2,
        automaticallyImplyLeading: true,
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
                        style: MyTheme.lightTextTheme.headline5,
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
                        style: MyTheme.lightTextTheme.bodyText1.copyWith(color: MyTheme.appolloGreen),
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
        padding: EdgeInsets.all(MyTheme.elementSpacing),
        child: PaymentPage(widget.linkType,
            discount: widget.discount,
            selectedTickets: widget.selectedTickets,
            maxHeight: MediaQuery.of(context).size.height),
      ),
    );
  }
}
