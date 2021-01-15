import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:webapp/UI/theme.dart';
import 'package:webapp/model/link_type/link_type.dart';
import 'package:webapp/pages/accept_invitation/bloc/accept_invitation_bloc.dart';
import 'package:webapp/repositories/user_repository.dart';

class FreeTicketPage extends StatefulWidget {
  final LinkType linkType;

  const FreeTicketPage(this.linkType, {Key key}) : super(key: key);

  @override
  _FreeTicketPageState createState() => _FreeTicketPageState();
}

class _FreeTicketPageState extends State<FreeTicketPage> {
  AcceptInvitationBloc bloc = AcceptInvitationBloc();

  @override
  void initState() {
    bloc.add(EventCheckInvitationStatus(UserRepository.instance.currentUser.firebaseUserID, widget.linkType.event));
    super.initState();
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AcceptInvitationBloc, AcceptInvitationState>(
        cubit: bloc,
        builder: (c, state) {
          if (state is StateInvitationPending) {
            return SizedBox(
              width: MyTheme.maxWidth,
              child: Card(
                  child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    AutoSizeText("This event offers a free ticket!",
                        style: MyTheme.mainTT.subtitle1),
                    SizedBox(
                      height: 18,
                    ),
                    AutoSizeText(state.release.name,
                        style: MyTheme.mainTT.headline6),
                    SizedBox(
                      height: 18,
                    ),
                    AutoSizeText("Planning to attend? Press the button below and we'll put you on the guest list",
                        style: MyTheme.mainTT.bodyText1),
                    SizedBox(
                      height: 12,
                    ),
                    SizedBox(
                      width: 120,
                      height: 40,
                      child: RaisedButton(
                        onPressed: () {
                          bloc.add(EventAcceptInvitation(widget.linkType));
                        },
                        child: Text(
                          "Attend",
                          style: MyTheme.mainTT.button,
                        ),
                      ),
                    )
                  ],
                ),
              )).appolloCard,
            );
          } else if (state is StateInvitationAccepted) {
            return SizedBox(
              width: MyTheme.maxWidth,
              child: Card(
                  child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    AutoSizeText("You're on the guest list!", style: MyTheme.mainTT.subtitle1),
                    SizedBox(
                      height: 12,
                    ),
                    AutoSizeText(
                        "We've sent your ticket to ${UserRepository.instance.currentUser.email}, make sure to check your spam folder and please have this ticket ready to show at the door."),
                  ],
                ),
              )).appolloCard,
            );
          } else if (state is StateTicketAlreadyIssued) {
            return SizedBox(
              width: MyTheme.maxWidth,
              child: Card(
                  child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    AutoSizeText(
                      "You're already on the guest list!",
                      style: MyTheme.mainTT.subtitle1,
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    AutoSizeText(
                        "Seems like you're already on the guest list. Your ticket was sent to ${UserRepository.instance.currentUser.email}, on ${DateFormat.yMd().format(state.ticket.dateIssued)} ${DateFormat.Hm().format(state.ticket.dateIssued)}, please make sure to check your spam folder."),
                  ],
                ),
              )).appolloCard,
            );
          } else if (state is StateError) {
            return SizedBox(
              width: MyTheme.maxWidth,
              child: Card(
                  child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    AutoSizeText("Uh-oh", style: MyTheme.mainTT.subtitle1),
                    SizedBox(
                      height: 12,
                    ),
                    AutoSizeText(
                        "Something went wrong on our end. Please reload the page and try again. If this continues to happen, please contact us: contact@appollo.io"),
                  ],
                ),
              )).appolloCard,
            );
          } else if (state is StateNoTicketsLeft) {
            return SizedBox(
              width: MyTheme.maxWidth,
              child: Card(
                  child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    AutoSizeText("Oh no!", style: MyTheme.mainTT.subtitle1),
                    SizedBox(
                      height: 12,
                    ),
                    AutoSizeText("It looks like there are no more tickets left."),
                  ],
                ),
              )).appolloCard,
            );
          } else if (state is StatePastCutoffTime) {
            return SizedBox(
              width: MyTheme.maxWidth,
              child: Card(
                  child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    AutoSizeText("Oh no!", style: MyTheme.mainTT.subtitle1),
                    SizedBox(
                      height: 12,
                    ),
                    AutoSizeText(
                        "Looks like it's past the cutoff time for this event, no more invitations can be accepted."),
                  ],
                ),
              )).appolloCard,
            );
          } else {
            return SizedBox(
              width: MyTheme.maxWidth,
              child: Card(
                  child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 12,
                    ),
                    AutoSizeText("Fetching your invitation data, this won't take long ...")
                  ],
                ),
              )).appolloCard,
            );
          }
        });
  }
}
