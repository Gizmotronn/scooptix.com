import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/model/ticket.dart';
import 'package:ticketapp/utilities/format_date/full_date_time.dart';

class TicketEventPage extends StatelessWidget {
  final Ticket ticket;
  final bool isTicketPass;
  final BuildContext parentContext;
  const TicketEventPage({Key key, this.ticket, this.isTicketPass, this.parentContext}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: MyTheme.appolloCardColorLight,
        automaticallyImplyLeading: true,
        title: InkWell(
          onTap: () {
            Navigator.pop(parentContext);
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
                    "Event Ticket",
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
      body: Container(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Container(
                height: 64,
                color: MyTheme.appolloGreen,
                width: size.width,
                child: Center(
                    child: Text(
                  '${ticket.release.ticketName}',
                  style: MyTheme.textTheme.headline2.copyWith(fontWeight: FontWeight.w600),
                )),
              ).paddingBottom(MyTheme.elementSpacing),
              _eventDate().paddingBottom(MyTheme.elementSpacing),
              _eventName(context).paddingBottom(MyTheme.elementSpacing),
              _whereEvent(context).paddingBottom(MyTheme.elementSpacing),
            ],
          ),
          _qrCode(size).paddingBottom(MyTheme.elementSpacing),
          Container(
            height: 64,
            width: size.width,
            color: !isTicketPass ? MyTheme.appolloGreen : (ticket.wasUsed ? MyTheme.appolloGreen : MyTheme.appolloRed),
            child: Center(
                child: Text(
              !isTicketPass ? "Admit One" : (ticket.wasUsed ? 'Attended' : 'Did Not Attend'),
              style: MyTheme.textTheme.headline2.copyWith(fontWeight: FontWeight.w600),
            )),
          ),
        ],
      )),
    );
  }

  Widget _eventDate() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("appollo",
            style: MyTheme.textTheme.subtitle1.copyWith(
              fontFamily: "cocon",
              color: Colors.white,
              fontSize: 24,
            )),
        Text(
          "${time(ticket.event.date) + ' - ' + time(ticket.event.endTime)}\n${date(ticket.event.date)}",
        )
      ],
    ).paddingHorizontal(MyTheme.elementSpacing);
  }

  Widget _eventName(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context, title: 'Event'),
          Text(
            '${ticket.event.name}',
            style: MyTheme.textTheme.bodyText1,
          ),
        ],
      ).paddingHorizontal(MyTheme.elementSpacing),
    );
  }

  Widget _whereEvent(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context, title: 'Where'),
          Text('${ticket.event.address}', style: MyTheme.textTheme.bodyText1),
        ],
      ).paddingHorizontal(MyTheme.elementSpacing),
    );
  }

  Widget _qrCode(Size size) {
    return Container(
      height: size.height * 0.30,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white),
      child: SizedBox(
        child: QrImage(
          backgroundColor: MyTheme.appolloWhite,
          data: '${ticket.event.docID} ${ticket.docId}',
          version: QrVersions.auto,
        ),
      ).paddingAll(8),
    ).paddingAll(MyTheme.elementSpacing);
  }

  Widget _header(BuildContext context, {String title}) => Text(
        title,
        style: Theme.of(context).textTheme.headline5.copyWith(color: MyTheme.appolloGreen, fontWeight: FontWeight.w600),
      ).paddingVertical(8);
}
