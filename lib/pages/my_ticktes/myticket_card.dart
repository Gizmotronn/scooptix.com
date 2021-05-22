import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/model/ticket.dart';
import 'package:ticketapp/pages/my_ticktes/ticket_event_page.dart';
import 'package:ticketapp/utilities/format_date/full_date_time.dart';
import 'package:ticketapp/utilities/svg/icon.dart';

class MyTicketCard extends StatelessWidget {
  final Ticket ticket;
  final bool isPastTicket;
  final BuildContext sheetContext;

  const MyTicketCard({Key key, @required this.ticket, this.isPastTicket = false, this.sheetContext}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            sheetContext,
            MaterialPageRoute(
                builder: (c) => TicketEventPage(
                      ticket: ticket,
                      isTicketPass: isPastTicket,
                      parentContext: context,
                    )));
      },
      child: Row(
        children: [
          Expanded(
            child: ClipPath(
              clipper: TicketClipper(isCard1: true),
              child: Container(
                color: MyTheme.appolloCardColorLight,
                height: MediaQuery.of(context).size.width / 1.9 / 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            fullDateWithDay(ticket.event.date) ?? '',
                            textAlign: TextAlign.start,
                            maxLines: 2,
                            style: MyTheme.textTheme.subtitle2.copyWith(color: MyTheme.appolloRed),
                          ).paddingBottom(8),
                        ),
                      ],
                    ),
                    AutoSizeText(
                      ticket.event.name ?? '',
                      textAlign: TextAlign.start,
                      maxLines: 2,
                      overflow: TextOverflow.clip,
                      style: MyTheme.textTheme.headline5,
                    ),
                    Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            ticket.event.address ?? '',
                            textAlign: TextAlign.start,
                            maxLines: 2,
                            style: MyTheme.textTheme.subtitle2.copyWith(color: MyTheme.appolloWhite),
                          ),
                        ),
                      ],
                    ),
                  ],
                ).paddingAll(8),
              ),
            ),
          ),
          ClipPath(
            clipper: TicketClipper(),
            child: Container(
              height: MediaQuery.of(context).size.width / 1.9 / 2,
              color: isPastTicket ? MyTheme.appolloRed : MyTheme.appolloGreen,
              width: MediaQuery.of(context).size.width * 0.25,
              child: _checkTicket(isPastTicket).paddingAll(8),
            ).paddingLeft(2.5),
          ),
        ],
      ),
    );
  }

  Widget _checkTicket(bool isPassTicket) {
    if (isPastTicket && !ticket.wasUsed) {
      return _qrCard('Did Not Attend', 'Expired');
    }
    if (isPastTicket && ticket.wasUsed) {
      return _qrCard('Attended', 'Expired');
    }
    return _qrCard("Admit One", 'View Ticket');
  }

  Widget _qrCard(String title, String subTitle) {
    return Column(
      children: [
        Text(
          title,
          style: MyTheme.textTheme.caption.copyWith(color: MyTheme.appolloWhite),
        ),
        Expanded(
          child: SvgPicture.asset(AppolloSvgIcon.qrScan).paddingAll(4),
        ),
        Text(
          subTitle,
          style: MyTheme.textTheme.caption.copyWith(color: MyTheme.appolloWhite, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class TicketClipper extends CustomClipper<Path> {
  final bool isCard1;
  const TicketClipper({this.isCard1 = false});
  final double radius = 8;

  @override
  Path getClip(Size size) {
    Path path = Path()
      ..moveTo(0, radius)
      ..arcToPoint(Offset(radius, 0), radius: Radius.circular(radius), clockwise: isCard1)
      ..lineTo(size.width - radius, 0)
      ..arcToPoint(Offset(size.width, radius), radius: Radius.circular(radius), clockwise: false)
      ..lineTo(size.width, size.height - radius)
      ..arcToPoint(Offset(size.width - radius, size.height), radius: Radius.circular(radius), clockwise: false)
      ..lineTo(size.width - radius, size.height)
      ..lineTo(radius, size.height)
      ..arcToPoint(Offset(0, size.height - radius), radius: Radius.circular(radius), clockwise: isCard1)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
