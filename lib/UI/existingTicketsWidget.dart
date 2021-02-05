import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:webapp/model/link_type/birthdayList.dart';
import 'package:webapp/model/link_type/link_type.dart';
import 'package:webapp/model/ticket.dart';
import 'package:webapp/repositories/user_repository.dart';
import 'theme.dart';

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
    return Card(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: SizedBox(
            width: MyTheme.maxWidth,
            child: Column(
              children: [
                AutoSizeText(
                    "Here are your tickets. We've also sent them to ${UserRepository.instance.currentUser.email}.", textAlign: TextAlign.center,),
                ListView.builder(
                  padding: EdgeInsets.zero,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: widget.ticket.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        AutoSizeText(widget.linkType is Booking ? "Birthday List Invitation" : "Event Ticket", style: MyTheme.mainTT.headline6.copyWith(color: MyTheme.appolloGreen)),
                        SizedBox(
                          height: 24,
                        ),
                        AutoSizeText(widget.ticket[index].release.name),
                        SizedBox(
                          height: 16,
                        ),
                        QrImage(
                          backgroundColor: MyTheme.appolloWhite,
                          data: '${widget.ticket[index].event.docID} ${widget.ticket[index].docId}',
                          version: QrVersions.auto,
                          size: MyTheme.maxWidth - 32,
                          gapless: true,
                        )
                      ],
                    ).paddingTop(16);
                  }
                ),
              ],
            ),
          ),
        )).appolloCard;
  }
}
