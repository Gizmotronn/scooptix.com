import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:ticketapp/UI/event_details/eventInfo.dart';
import 'package:ticketapp/UI/event_details/existingTicketsWidget.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/buttons/apollo_button.dart';
import 'package:ticketapp/main.dart';
import 'package:ticketapp/model/link_type/link_type.dart';
import 'package:ticketapp/pages/event_details/authentication_drawer.dart';
import 'package:ticketapp/repositories/user_repository.dart';
import 'bloc/invitation_bloc.dart';

class InvitationPage extends StatefulWidget {
  final LinkType linkType;
  final bool forwardToPayment;

  const InvitationPage(this.linkType, {Key key, @required this.forwardToPayment}) : super(key: key);

  @override
  _InvitationPageState createState() => _InvitationPageState();
}

class _InvitationPageState extends State<InvitationPage> {
  InvitationBloc bloc = InvitationBloc();

  @override
  void initState() {
    if (UserRepository.instance.currentUser() != null) {
      bloc.add(EventCheckInvitationStatus(
          UserRepository.instance.currentUser().firebaseUserID, widget.linkType.event, widget.forwardToPayment));
    }
    super.initState();
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (UserRepository.instance.currentUser() == null) {
      return Column(
        children: [
          Text("Please login to proceed to checkout").paddingBottom(MyTheme.elementSpacing),
          AppolloButton.mediumButton(
              child: Text(
                "Login",
                style: MyTheme.lightTextTheme.button,
              ),
              onTap: () {
                WrapperPage.endDrawer.value = AuthenticationDrawer();
                WrapperPage.mainScaffold.currentState.openEndDrawer();
              }),
        ],
      );
    }
    return WillPopScope(
      onWillPop: () async {
        bloc.add(EventCheckInvitationStatus(
            UserRepository.instance.currentUser().firebaseUserID, widget.linkType.event, false));
        return false;
      },
      child: BlocBuilder<InvitationBloc, InvitationState>(
          cubit: bloc,
          builder: (c, state) {
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
                            .appolloCard()
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
                      AutoSizeText(
                        "Uh-oh",
                        style: MyTheme.lightTextTheme.subtitle1,
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      AutoSizeText(
                        "Something went wrong on our end. Please reload the page and try again. If this continues to happen, please contact us: contact@appollo.io",
                        style: MyTheme.lightTextTheme.bodyText2,
                      ),
                    ],
                  ),
                )).appolloCard(),
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
                    )).appolloCard(),
                  );
                } else {
                  return SizedBox(
                    width: MyTheme.maxWidth,
                    child: Column(
                      children: [
                        AutoSizeText("Oh no!", style: MyTheme.lightTextTheme.subtitle1),
                        SizedBox(
                          height: 12,
                        ),
                        AutoSizeText("It looks like there are currently no tickets for sale.",
                            style: MyTheme.lightTextTheme.bodyText2),
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
                      AutoSizeText(
                        "Oh no!",
                        style: MyTheme.lightTextTheme.subtitle1,
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      AutoSizeText(
                          "Looks like it's past the cutoff time for this event, no more invitations can be accepted.",
                          style: MyTheme.lightTextTheme.bodyText2),
                    ],
                  ),
                )).appolloCard(),
              );
            } /*else if (state is StateWaitForPayment) {
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
                  return PaymentPage(widget.linkType, bloc,
                      textTheme: MyTheme.lightTextTheme, maxWidth: MyTheme.drawerSize);
                }
              });
            }*/
            else if (state is StatePaymentRequired) {
              return Column(
                children: [
                  ResponsiveBuilder(builder: (context, constraints) {
                    if (constraints.deviceScreenType == DeviceScreenType.mobile ||
                        constraints.deviceScreenType == DeviceScreenType.watch) {
                      return Column(
                        children: [
                          Container(child: EventInfoWidget(Axis.vertical, widget.linkType))
                              .appolloCard()
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
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: MyTheme.appolloGreen,
                                      ),
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
                            )).appolloCard(),
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
                                  AutoSizeText("VIP Invitation Conditions", style: MyTheme.lightTextTheme.headline6),
                                  SizedBox(
                                    height: MyTheme.elementSpacing * 0.5,
                                  ),
                                  AutoSizeText(widget.linkType.event.invitationMessage,
                                      style: MyTheme.lightTextTheme.bodyText2),
                                  SizedBox(
                                    height: MyTheme.elementSpacing,
                                  ),
                                ],
                              ),
                            SizedBox(
                              width: MyTheme.maxWidth,
                              height: 34,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: MyTheme.appolloGreen,
                                ),
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
                    )).appolloCard();
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
                            style: MyTheme.lightTextTheme.bodyText2,
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
