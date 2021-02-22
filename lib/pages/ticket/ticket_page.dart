import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:webapp/UI/eventInfo.dart';
import 'package:webapp/UI/existingTicketsWidget.dart';
import 'package:webapp/UI/theme.dart';
import 'package:webapp/model/link_type/link_type.dart';
import 'package:webapp/pages/ticket/bloc/ticket_bloc.dart';
import 'package:webapp/pages/payment/payment_page.dart';
import 'package:webapp/repositories/user_repository.dart';

class TicketPage extends StatefulWidget {
  final LinkType linkType;
  final bool forwardToPayment;

  const TicketPage(this.linkType, {Key key, @required this.forwardToPayment}) : super(key: key);

  @override
  _TicketPageState createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  TicketBloc bloc = TicketBloc();

  @override
  void initState() {
    bloc.add(EventCheckInvitationStatus(
        UserRepository.instance.currentUser.firebaseUserID, widget.linkType.event, widget.forwardToPayment));
    super.initState();
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bloc.add(EventCheckInvitationStatus(
            UserRepository.instance.currentUser.firebaseUserID, widget.linkType.event, false));
        return false;
      },
      child: BlocBuilder<TicketBloc, TicketState>(
          cubit: bloc,
          builder: (c, state) {
            print(state);
            if (state is StateInvitationAccepted) {
              return SizedBox(
                width: MyTheme.maxWidth,
                child: ExistingTicketsWidget(state.tickets, widget.linkType),
              );
            } else if (state is StateTicketAlreadyIssued) {
              return SizedBox(
                width: MyTheme.maxWidth,
                child: Column(
                  children: [
                    ResponsiveBuilder(builder: (context, constraints) {
                      if (constraints.deviceScreenType == DeviceScreenType.mobile ||
                          constraints.deviceScreenType == DeviceScreenType.watch) {
                        return Container(child: EventInfoWidget(Axis.vertical, widget.linkType))
                            .appolloCard
                            .paddingBottom(8);
                      } else {
                        return SizedBox.shrink();
                      }
                    }),
                    ExistingTicketsWidget([state.ticket], widget.linkType),
                  ],
                ),
              );
            } else if (state is StateError) {
              return SizedBox(
                width: MyTheme.maxWidth,
                child: Container(
                    child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      AutoSizeText("Uh-oh",
                          style: getValueForScreenType(
                              context: context,
                              watch: MyTheme.lightTextTheme.subtitle1,
                              mobile: MyTheme.lightTextTheme.subtitle1,
                              tablet: MyTheme.darkTextTheme.subtitle1,
                              desktop: MyTheme.darkTextTheme.subtitle1)),
                      SizedBox(
                        height: 12,
                      ),
                      AutoSizeText(
                          "Something went wrong on our end. Please reload the page and try again. If this continues to happen, please contact us: contact@appollo.io",
                          style: getValueForScreenType(
                              context: context,
                              watch: MyTheme.lightTextTheme.bodyText2,
                              mobile: MyTheme.lightTextTheme.bodyText2,
                              tablet: MyTheme.darkTextTheme.bodyText2,
                              desktop: MyTheme.darkTextTheme.bodyText2)),
                    ],
                  ),
                )).appolloCard,
              );
            } else if (state is StateNoTicketsLeft) {
              return ResponsiveBuilder(builder: (context, constraints) {
                if (constraints.deviceScreenType == DeviceScreenType.mobile ||
                    constraints.deviceScreenType == DeviceScreenType.watch) {
                  return SizedBox(
                    width: MyTheme.maxWidth,
                    child: Container(
                        child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          AutoSizeText("Oh no!", style: MyTheme.lightTextTheme.subtitle1),
                          SizedBox(
                            height: 12,
                          ),
                          AutoSizeText("It looks like there are no more tickets left."),
                        ],
                      ),
                    )).appolloCard,
                  );
                } else {
                  return SizedBox(
                    width: MyTheme.maxWidth,
                    child: Column(
                      children: [
                        AutoSizeText("Oh no!", style: MyTheme.darkTextTheme.subtitle1),
                        SizedBox(
                          height: 12,
                        ),
                        AutoSizeText("It looks like there are currently no tickets for sale.",
                            style: MyTheme.darkTextTheme.bodyText2),
                      ],
                    ),
                  );
                }
              });
            } else if (state is StatePastCutoffTime) {
              return SizedBox(
                width: MyTheme.maxWidth,
                child: Container(
                    child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      AutoSizeText("Oh no!",
                          style: getValueForScreenType(
                              context: context,
                              watch: MyTheme.lightTextTheme.subtitle1,
                              mobile: MyTheme.lightTextTheme.subtitle1,
                              tablet: MyTheme.darkTextTheme.subtitle1,
                              desktop: MyTheme.darkTextTheme.subtitle1)),
                      SizedBox(
                        height: 12,
                      ),
                      AutoSizeText(
                          "Looks like it's past the cutoff time for this event, no more invitations can be accepted.",
                          style: getValueForScreenType(
                              context: context,
                              watch: MyTheme.lightTextTheme.bodyText2,
                              mobile: MyTheme.lightTextTheme.bodyText2,
                              tablet: MyTheme.darkTextTheme.bodyText2,
                              desktop: MyTheme.darkTextTheme.bodyText2)),
                    ],
                  ),
                )).appolloCard,
              );
            } else if (state is StateWaitForPayment) {
              return ResponsiveBuilder(builder: (context, constraints) {
                if (constraints.deviceScreenType == DeviceScreenType.mobile ||
                    constraints.deviceScreenType == DeviceScreenType.watch) {
                  return PaymentPage(
                    widget.linkType,
                    bloc,
                    textTheme: MyTheme.lightTextTheme,
                    maxWidth: MyTheme.maxWidth,
                  );
                } else {
                  return PaymentPage(widget.linkType, bloc, textTheme: MyTheme.darkTextTheme, maxWidth: 500);
                }
              });
            } else if (state is StatePaymentRequired) {
              return Column(
                children: [
                  ResponsiveBuilder(builder: (context, constraints) {
                    if (constraints.deviceScreenType == DeviceScreenType.mobile ||
                        constraints.deviceScreenType == DeviceScreenType.watch) {
                      return Column(
                        children: [
                          Container(child: EventInfoWidget(Axis.vertical, widget.linkType))
                              .appolloCard
                              .paddingBottom(8),
                          SizedBox(
                            width: MyTheme.maxWidth,
                            child: Container(
                                child: Padding(
                              padding: EdgeInsets.all(MyTheme.cardPadding),
                              child: Column(
                                children: [
                                  AutoSizeText("Accept your invitation", style: MyTheme.lightTextTheme.subtitle1),
                                  SizedBox(
                                    height: 18,
                                  ),
                                  SizedBox(
                                    width: MyTheme.maxWidth,
                                    height: 34,
                                    child: RaisedButton(
                                      color: MyTheme.appolloGreen,
                                      onPressed: () {
                                        bloc.add(EventGoToPayment(state.releases));
                                      },
                                      child: Text(
                                        "Get Your Ticket",
                                        style: MyTheme.lightTextTheme.button,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )).appolloCard,
                          ).paddingBottom(8),
                        ],
                      );
                    } else {
                      return SizedBox(
                        width: MyTheme.maxWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.linkType.event.invitationMessage != "")
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AutoSizeText("VIP Invitation Conditions", style: MyTheme.darkTextTheme.headline6),
                                  SizedBox(
                                    height: MyTheme.elementSpacing * 0.5,
                                  ),
                                  AutoSizeText(widget.linkType.event.invitationMessage,
                                      style: MyTheme.darkTextTheme.bodyText2),
                                  SizedBox(
                                    height: MyTheme.elementSpacing,
                                  ),
                                ],
                              ),
                            SizedBox(
                              width: MyTheme.maxWidth,
                              height: 34,
                              child: RaisedButton(
                                color: MyTheme.appolloGreen,
                                onPressed: () {
                                  bloc.add(EventGoToPayment(state.releases));
                                },
                                child: Text(
                                  "Get Your Ticket",
                                  style: MyTheme.lightTextTheme.button,
                                ),
                              ),
                            )
                          ],
                        ).paddingBottom(MyTheme.elementSpacing),
                      );
                    }
                  }),
                  if (state.tickets.length > 0) ExistingTicketsWidget(state.tickets, widget.linkType),
                ],
              );
            } else {
              return SizedBox(
                width: MyTheme.maxWidth,
                child: ResponsiveBuilder(builder: (context, constraints) {
                  if (constraints.deviceScreenType == DeviceScreenType.mobile ||
                      constraints.deviceScreenType == DeviceScreenType.watch) {
                    return Container(
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
                    )).appolloCard;
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(
                            height: 12,
                          ),
                          AutoSizeText(
                            "Fetching your invitation data, this won't take long",
                            style: MyTheme.darkTextTheme.bodyText2,
                          )
                        ],
                      ),
                    );
                  }
                }),
              );
            }
          }),
    );
  }
}
