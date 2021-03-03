import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:webapp/UI/event_details/downloadAppollo.dart';
import 'package:webapp/model/link_type/birthdayList.dart';
import 'package:webapp/model/link_type/invitation.dart';
import 'package:webapp/model/link_type/link_type.dart';
import 'package:webapp/model/ticket.dart';
import 'package:webapp/repositories/user_repository.dart';
import '../theme.dart';

/// Displays a message that the user already has tickets for this event
/// If on mobile view, also displays QR codes for those tickets
class ExistingTicketsWidget extends StatefulWidget {
  final List<Ticket> ticket;
  final LinkType linkType;

  const ExistingTicketsWidget(this.ticket, this.linkType, {Key key}) : super(key: key);

  @override
  _ExistingTicketsWidgetState createState() => _ExistingTicketsWidgetState();
}

class _ExistingTicketsWidgetState extends State<ExistingTicketsWidget> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, constraints) {
      if (constraints.deviceScreenType == DeviceScreenType.mobile ||
          constraints.deviceScreenType == DeviceScreenType.watch) {
        String ticketText;
        if (widget.linkType is Booking || widget.linkType is Invitation) {
          ticketText =
              "Here is your ticket. We've also sent it to ${UserRepository.instance.currentUser.email}. Please note: This event only allows one ticket per person.";
        } else {
          ticketText =
              "Here are your previously bought tickets. We've also sent them to ${UserRepository.instance.currentUser.email}.";
        }
        return Container(
            child: Padding(
          padding: EdgeInsets.all(8),
          child: SizedBox(
            width: MyTheme.maxWidth,
            child: Column(
              children: [
                AutoSizeText(
                  ticketText,
                  textAlign: TextAlign.center,
                ).paddingLeft(8).paddingRight(8).paddingBottom(MyTheme.elementSpacing * 0.5),
                DownloadAppolloWidget().paddingBottom(8),
                ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: widget.ticket.length,
                    itemBuilder: (context, index) {
                      return Container(
                        child: Column(
                          children: [
                            AutoSizeText(widget.linkType is Booking ? "Birthday List Invitation" : "Event Ticket",
                                style: MyTheme.lightTextTheme.headline6.copyWith(color: MyTheme.appolloGreen)),
                            SizedBox(
                              height: MyTheme.elementSpacing,
                            ),
                            AutoSizeText(widget.ticket[index].release.name),
                            SizedBox(
                              height: MyTheme.elementSpacing * 0.5,
                            ),
                            Center(
                              child: QrImage(
                                backgroundColor: MyTheme.appolloWhite,
                                data: '${widget.ticket[index].event.docID} ${widget.ticket[index].docId}',
                                version: QrVersions.auto,
                                size: MyTheme.maxWidth * 0.8,
                                gapless: true,
                              ),
                            ).paddingBottom(MyTheme.elementSpacing)
                          ],
                        ).paddingTop(16),
                      ).appolloCard.paddingBottom(8);
                    }),
              ],
            ),
          ),
        )).appolloCard;
      } else {
        String ticketHeadline;
        String ticketText;
        if (widget.linkType.event.getReleasesWithoutRestriction().length == 0) {
          ticketHeadline = "Invitation Accepted";
          ticketText =
              "We've sent your ticket to ${UserRepository.instance.currentUser.email}. Please note: This event only allows one ticket per person.";
        } else {
          ticketHeadline = "Your Tickets";
          ticketText =
              "You already bought tickets for this event. We've sent them to ${UserRepository.instance.currentUser.email}.";
        }
        return SizedBox(
          width: MyTheme.maxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              AutoSizeText(
                ticketHeadline,
                style: MyTheme.darkTextTheme.headline5,
              ).paddingBottom(MyTheme.elementSpacing),
              if (widget.linkType.event.invitationMessage != "")
                AutoSizeText(
                  widget.linkType.event.invitationMessage,
                  style: MyTheme.darkTextTheme.bodyText2,
                ).paddingBottom(MyTheme.elementSpacing),
              AutoSizeText(
                ticketText,
                style: MyTheme.darkTextTheme.bodyText2,
              ).paddingBottom(MyTheme.elementSpacing * 2),
              DownloadAppolloWidget()
            ],
          ),
        );
      }
    });
  }
}
