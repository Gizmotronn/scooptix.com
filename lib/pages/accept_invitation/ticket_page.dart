import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:webapp/UI/downloadAppollo.dart';
import 'package:webapp/UI/eventInfo.dart';
import 'package:webapp/UI/existingTicketsWidget.dart';
import 'package:webapp/UI/theme.dart';
import 'package:webapp/model/link_type/link_type.dart';
import 'package:webapp/pages/accept_invitation/bloc/ticket_bloc.dart';
import 'package:webapp/pages/payment/payment_page.dart';
import 'package:webapp/repositories/user_repository.dart';
import 'package:webapp/utilities/alertGenerator.dart';

class TicketPage extends StatefulWidget {
  final LinkType linkType;

  const TicketPage(this.linkType, {Key key}) : super(key: key);

  @override
  _TicketPageState createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  TicketBloc bloc = TicketBloc();

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
    return Padding(
      padding: const EdgeInsets.all(4),
      child: BlocBuilder<TicketBloc, TicketState>(
          cubit: bloc,
          builder: (c, state) {
            print(state);
            if (state is StateNoPaymentRequired) {
              return Column(
                children: [
                  ResponsiveBuilder(builder: (context, constraints) {
                    if (constraints.deviceScreenType == DeviceScreenType.mobile ||
                        constraints.deviceScreenType == DeviceScreenType.watch) {
                      return Card(child: EventInfoWidget(Axis.vertical, widget.linkType.event)).appolloCard;
                    } else {
                      return EventInfoWidget(Axis.horizontal, widget.linkType.event);
                    }
                  }),
                  SizedBox(
                    width: MyTheme.maxWidth,
                    child: Card(
                        child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          AutoSizeText("Accept your invitation", style: MyTheme.mainTT.subtitle1),
                          SizedBox(
                            height: 18,
                          ),
                          AutoSizeText(state.releases[0].name, style: MyTheme.mainTT.headline6),
                          SizedBox(
                            height: 12,
                          ),
                          SizedBox(
                            width: MyTheme.maxWidth,
                            height: 34,
                            child: RaisedButton(
                              color: MyTheme.appolloGreen,
                              onPressed: () {
                                if (widget.linkType.event.ticketCheckoutMessage != null) {
                                  AlertGenerator.showAlertWithChoice(
                                          context: context,
                                          title: "Please note",
                                          content: widget.linkType.event.ticketCheckoutMessage,
                                          buttonText1: "I Understand",
                                          buttonText2: "Cancel")
                                      .then((value) {
                                    if (value != null && value) {
                                      bloc.add(EventAcceptInvitation(widget.linkType, state.selectedRelease));
                                    }
                                  });
                                } else {
                                  bloc.add(EventAcceptInvitation(widget.linkType, state.selectedRelease));
                                }
                              },
                              child: Text(
                                "Accept Invitation",
                                style: MyTheme.mainTT.button,
                              ),
                            ),
                          )
                        ],
                      ),
                    )).appolloCard,
                  ),
                ],
              );
            } else if (state is StateInvitationAccepted) {
              return SizedBox(
                width: MyTheme.maxWidth,
                child: Column(
                  children: [
                    DownloadAppolloWidget(),
                    ExistingTicketsWidget(state.tickets, widget.linkType),
                    Card(
                        child: EventInfoWidget(
                      Axis.vertical,
                      widget.linkType.event,
                      showTitleAndImage: false,
                    )).appolloCard
                  ],
                ),
              );
            } else if (state is StateTicketAlreadyIssued) {
              return SizedBox(
                width: MyTheme.maxWidth,
                child: Column(
                  children: [
                    ResponsiveBuilder(builder: (context, constraints) {
                      if (constraints.deviceScreenType == DeviceScreenType.mobile ||
                          constraints.deviceScreenType == DeviceScreenType.watch) {
                        return Card(child: EventInfoWidget(Axis.vertical, widget.linkType.event)).appolloCard;
                      } else {
                        return EventInfoWidget(Axis.horizontal, widget.linkType.event);
                      }
                    }),
                    ExistingTicketsWidget([state.ticket], widget.linkType),

                  ],
                ),
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
            } else if (state is StateWaitForPayment) {
              return PaymentPage(widget.linkType, bloc);
            } else if (state is StatePaymentRequired) {
              return Column(
                children: [
                  ResponsiveBuilder(builder: (context, constraints) {
                    if (constraints.deviceScreenType == DeviceScreenType.mobile ||
                        constraints.deviceScreenType == DeviceScreenType.watch) {
                      return Card(child: EventInfoWidget(Axis.vertical, widget.linkType.event)).appolloCard;
                    } else {
                      return EventInfoWidget(Axis.horizontal, widget.linkType.event);
                    }
                  }),
                  SizedBox(
                    width: MyTheme.maxWidth,
                    child: Card(
                        child: Padding(
                      padding: EdgeInsets.all(MyTheme.cardPadding),
                      child: Column(
                        children: [
                          AutoSizeText("Accept your invitation", style: MyTheme.mainTT.subtitle1),
                          SizedBox(
                            height: 18,
                          ),
                          SizedBox(
                            width: MyTheme.maxWidth,
                            height: 34,
                            child: RaisedButton(
                              color: MyTheme.appolloGreen,
                              onPressed: () {
                                if (widget.linkType.event.ticketCheckoutMessage != null) {
                                  AlertGenerator.showAlertWithChoice(
                                          context: context,
                                          title: "Please note",
                                          content: widget.linkType.event.ticketCheckoutMessage,
                                          buttonText1: "I Understand",
                                          buttonText2: "Cancel")
                                      .then((value) {
                                    if (value != null && value) {
                                      bloc.add(EventGoToPayment(state.releases));
                                    }
                                  });
                                } else {
                                  bloc.add(EventGoToPayment(state.releases));
                                }
                              },
                              child: Text(
                                "Create Your Order",
                                style: MyTheme.mainTT.button,
                              ),
                            ),
                          )
                        ],
                      ),
                    )).appolloCard,
                  ),
                  if (state.tickets.length > 0) ExistingTicketsWidget(state.tickets, widget.linkType),
                ],
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
                      AutoSizeText("Fetching your invitation data, this won't take long")
                    ],
                  ),
                )).appolloCard,
              );
            }
          }),
    );
  }
}
