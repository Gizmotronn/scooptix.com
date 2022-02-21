import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/scooptix_logo.dart';
import 'package:ticketapp/model/ticket.dart';
import 'package:ticketapp/utilities/format_date/full_date_time.dart';

class TicketEventPage extends StatelessWidget {
  final Ticket ticket;
  final bool isTicketPass;
  final BuildContext parentContext;
  const TicketEventPage({Key? key, required this.ticket, required this.isTicketPass, required this.parentContext})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (c, size) {
        if (size.isDesktop || size.isTablet) {
          return Container(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Event Ticket",
                        style: MyTheme.textTheme.headline2,
                      )
                          .paddingBottom(MyTheme.elementSpacing * 2)
                          .paddingTop(MyTheme.elementSpacing)
                          .paddingLeft(MyTheme.elementSpacing)),
                  _eventDate().paddingBottom(MyTheme.elementSpacing),
                  _eventName(context).paddingBottom(MyTheme.elementSpacing),
                  _eventLocation(context).paddingBottom(MyTheme.elementSpacing),
                ],
              ),
              Expanded(child: _qrCodeDesktop(size.screenSize).paddingBottom(MyTheme.elementSpacing)),
            ],
          ));
        } else {
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: MyTheme.scoopCardColorLight,
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
                          style: MyTheme.textTheme.bodyText1!.copyWith(color: MyTheme.scoopGreen),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Container(
                  constraints: BoxConstraints(
                      minHeight:
                          MediaQuery.of(context).size.height - MyTheme.appBarHeight - MyTheme.bottomNavBarHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Container(
                            height: 64,
                            color: MyTheme.scoopGreen,
                            width: size.screenSize.width,
                            child: Center(
                                child: Text(
                              '${ticket.release!.ticketName}',
                              style: MyTheme.textTheme.headline2!.copyWith(fontWeight: FontWeight.w600),
                            )),
                          ).paddingBottom(MyTheme.elementSpacing),
                          _eventDate().paddingBottom(MyTheme.elementSpacing),
                          _eventName(context).paddingBottom(MyTheme.elementSpacing),
                          _eventLocation(context).paddingBottom(MyTheme.elementSpacing),
                        ],
                      ),
                      _qrCodeMobile(size.screenSize).paddingBottom(MyTheme.elementSpacing),
                      Container(
                        height: 64,
                        width: size.screenSize.width,
                        color: !isTicketPass
                            ? MyTheme.scoopGreen
                            : (ticket.wasUsed ? MyTheme.scoopGreen : MyTheme.scoopRed),
                        child: Center(
                            child: Text(
                          !isTicketPass ? "Admit One" : (ticket.wasUsed ? 'Attended' : 'Did Not Attend'),
                          style: MyTheme.textTheme.headline2!.copyWith(fontWeight: FontWeight.w600),
                        )),
                      ),
                    ],
                  )),
            ),
          );
        }
      },
    );
  }

  Widget _eventDate() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ScooptixLogo(),
        Text(
          "${time(ticket.event!.date)} - ${ticket.event!.endTime != null ? time(ticket.event!.endTime!) : ""}\n${date(ticket.event!.date)}",
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
            '${ticket.event!.name}',
            style: MyTheme.textTheme.bodyText1,
          ),
        ],
      ).paddingHorizontal(MyTheme.elementSpacing),
    );
  }

  Widget _eventLocation(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context, title: 'Where'),
          Text('${ticket.event!.address}', style: MyTheme.textTheme.bodyText1),
        ],
      ).paddingHorizontal(MyTheme.elementSpacing),
    );
  }

  Widget _qrCodeMobile(Size size) {
    return Container(
      height: size.height * 0.30,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white),
      child: SizedBox(
        child: QrImage(
          backgroundColor: MyTheme.scoopWhite,
          data: '${ticket.event!.docID} ${ticket.docId}',
          version: QrVersions.auto,
        ),
      ).paddingAll(8),
    ).paddingAll(MyTheme.elementSpacing);
  }

  Widget _qrCodeDesktop(Size size) {
    return Center(
      child: SizedBox(
        height: MyTheme.drawerSize * 0.8 + 33 + 33,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: MyTheme.drawerSize * 0.1,
              right: MyTheme.drawerSize * 0.1,
              child: Container(
                padding: EdgeInsets.only(top: 4),
                height: 40,
                decoration: ShapeDecoration(
                    color: MyTheme.scoopGreen,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(topRight: Radius.circular(8), topLeft: Radius.circular(8)))),
                width: MyTheme.drawerSize * 0.8,
                child: Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      '${ticket.release!.ticketName}',
                      style: MyTheme.textTheme.headline4!.copyWith(fontWeight: FontWeight.w600),
                    )),
              ),
            ),
            Positioned(
              bottom: 0,
              left: MyTheme.drawerSize * 0.1,
              right: MyTheme.drawerSize * 0.1,
              child: Container(
                padding: EdgeInsets.only(bottom: 4),
                decoration: ShapeDecoration(
                    color:
                        !isTicketPass ? MyTheme.scoopGreen : (ticket.wasUsed ? MyTheme.scoopGreen : MyTheme.scoopRed),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.only(bottomRight: Radius.circular(8), bottomLeft: Radius.circular(8)))),
                height: 40,
                width: MyTheme.drawerSize * 0.8,
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      !isTicketPass ? "Admit One" : (ticket.wasUsed ? 'Attended' : 'Did Not Attend'),
                      style: MyTheme.textTheme.headline4!.copyWith(fontWeight: FontWeight.w600),
                    )),
              ),
            ),
            Positioned(
              top: 34,
              left: MyTheme.drawerSize * 0.1,
              right: MyTheme.drawerSize * 0.1,
              child: Container(
                width: MyTheme.drawerSize * 0.8,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white),
                child: SizedBox(
                  child: QrImage(
                    backgroundColor: MyTheme.scoopWhite,
                    data: '${ticket.event!.docID} ${ticket.docId}',
                    version: QrVersions.auto,
                  ),
                ).paddingAll(8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, {required String title}) => Text(
        title,
        style: Theme.of(context).textTheme.headline5!.copyWith(color: MyTheme.scoopGreen, fontWeight: FontWeight.w600),
      ).paddingVertical(8);
}
