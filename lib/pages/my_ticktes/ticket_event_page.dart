import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/model/ticket.dart';
import 'package:ticketapp/utilities/format_date/full_date_time.dart';

class TicketEventPage extends StatelessWidget {
  final Ticket ticket;
  final bool isTicketPass;
  const TicketEventPage({Key key, this.ticket, this.isTicketPass}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
                    "Event Ticket",
                    style: MyTheme.lightTextTheme.headline5,
                  ),
                  Text(
                    "Done",
                    style: MyTheme.lightTextTheme.bodyText1.copyWith(color: MyTheme.appolloGreen),
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
          Container(
            height: 40,
            color: MyTheme.appolloGreen,
            width: size.width,
            child: Center(
                child: Text(
              '${ticket.release.ticketName}',
              style: Theme.of(context).textTheme.headline3.copyWith(color: Colors.white),
            )),
          ),
          _eventDate(),
          _eventName(context),
          _whereEvent(context),
          _qrCode(size),
          Container(
            height: 40,
            width: size.width,
            color:
                !isTicketPass ? MyTheme.appolloGreen : (ticket.isAttended ? MyTheme.appolloGreen : MyTheme.appolloRed),
            child: Center(
                child: Text(
              !isTicketPass ? "Admit One" : (ticket.isAttended ? 'Attended' : 'Did Not Attend'),
              style: Theme.of(context).textTheme.headline3.copyWith(color: Colors.white),
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
            style: MyTheme.lightTextTheme.subtitle1.copyWith(
                fontFamily: "cocon",
                color: Colors.white,
                fontSize: 20,
                shadows: [BoxShadow(color: Colors.black, blurRadius: 1, spreadRadius: 1)])),
        Text(
          "${time(ticket.event.date) + ' - ' + time(ticket.event.endTime)}\n${date(ticket.event.date)}",
        )
      ],
    ).paddingHorizontal(16);
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
            style: Theme.of(context)
                .textTheme
                .bodyText1
                .copyWith(color: MyTheme.appolloWhite, fontWeight: FontWeight.w500),
          ),
        ],
      ).paddingHorizontal(16),
    );
  }

  Widget _whereEvent(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context, title: 'Where'),
          Text(
            '${ticket.event.address}',
            style: Theme.of(context)
                .textTheme
                .bodyText1
                .copyWith(color: MyTheme.appolloWhite, fontWeight: FontWeight.w500),
          ),
        ],
      ).paddingHorizontal(16),
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
    ).paddingAll(16);
  }

  Widget _header(BuildContext context, {String title}) => Text(
        title,
        style: Theme.of(context).textTheme.headline5.copyWith(color: MyTheme.appolloGreen, fontWeight: FontWeight.w600),
      ).paddingVertical(8);
}
