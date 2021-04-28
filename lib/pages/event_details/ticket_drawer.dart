import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/model/link_type/link_type.dart';
import 'package:ticketapp/model/link_type/memberInvite.dart';
import 'package:ticketapp/pages/ticket/ticket_page.dart';
import 'package:ticketapp/repositories/user_repository.dart';

/// In the desktop view, most of the functionality is displayed in the end drawer.
class TicketDrawer extends StatefulWidget {
  final LinkType linkType;

  const TicketDrawer({Key key, @required this.linkType}) : super(key: key);

  @override
  _TicketDrawerState createState() => _TicketDrawerState();
}

class _TicketDrawerState extends State<TicketDrawer> {
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Container(
      width: MyTheme.drawerSize,
      height: screenSize.height,
      decoration: ShapeDecoration(
          color: MyTheme.appolloBackgroundColor,
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
                color: MyTheme.appolloRed,
              ),
            ),
          ).paddingTop(16).paddingRight(16).paddingTop(8),
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: MyTheme.cardPadding),
              constraints: BoxConstraints(minHeight: screenSize.height * 0.9),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Event Summary", style: MyTheme.lightTextTheme.headline4)
                          .paddingBottom(MyTheme.elementSpacing),
                      Text(
                        widget.linkType.event.name,
                        style: MyTheme.lightTextTheme.headline3,
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
                                  style: Theme.of(context).textTheme.subtitle2,
                                ).paddingBottom(8),
                                Text(
                                  "Duration:",
                                  style: Theme.of(context).textTheme.subtitle2,
                                ).paddingBottom(8),
                                Text(
                                  "Location:",
                                  style: Theme.of(context).textTheme.subtitle2,
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
                                    DateFormat.yMMMMd().format(widget.linkType.event.date),
                                    style: Theme.of(context).textTheme.bodyText2,
                                  ).paddingBottom(8),
                                  if (widget.linkType.event.endTime != null)
                                    AutoSizeText(
                                      "${DateFormat.jm().format(widget.linkType.event.date)} - ${DateFormat.jm().format(widget.linkType.event.endTime)} (${widget.linkType.event.endTime.difference(widget.linkType.event.date).inHours} Hours)",
                                      style: Theme.of(context).textTheme.bodyText2,
                                    ).paddingBottom(8),
                                  if (widget.linkType.event.endTime == null)
                                    AutoSizeText(
                                      "${DateFormat.jm().format(widget.linkType.event.date)} ",
                                      style: Theme.of(context).textTheme.bodyText2,
                                    ).paddingBottom(8),
                                  AutoSizeText(
                                    widget.linkType.event.address ?? widget.linkType.event.venueName,
                                    style: Theme.of(context).textTheme.bodyText2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ).paddingBottom(MyTheme.elementSpacing),
                      widget.linkType is MemberInvite &&
                              (widget.linkType as MemberInvite).promoter.docId ==
                                  UserRepository.instance.currentUser().firebaseUserID
                          ? Center(
                              child: Text("You can't invite yourself to this event",
                                  style: MyTheme.darkTextTheme.bodyText2))
                          : TicketPage(
                              widget.linkType,
                              forwardToPayment: true,
                            ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Events Powered By", style: MyTheme.darkTextTheme.bodyText2.copyWith(color: Colors.grey))
                          .paddingRight(4),
                      Text("appollo",
                          style: MyTheme.darkTextTheme.subtitle1.copyWith(
                            fontFamily: "cocon",
                            color: MyTheme.appolloPurple,
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
