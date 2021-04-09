import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:ticketapp/UI/event_details/eventInfo.dart';
import 'package:ticketapp/UI/event_details/whyAreYouHere.dart';
import 'package:ticketapp/UI/widgets/appollo/powered_by_appollo.dart';
import 'package:ticketapp/UI/widgets/backgrounds/events_details_background.dart';
import 'package:ticketapp/model/link_type/advertisementInvite.dart';
import 'package:ticketapp/model/link_type/birthdayList.dart';
import 'package:ticketapp/model/link_type/link_type.dart';
import 'package:ticketapp/model/link_type/overview.dart';
import 'package:ticketapp/model/link_type/promoterInvite.dart';
import 'package:ticketapp/pages/authentication/bloc/authentication_bloc.dart';
import 'package:ticketapp/pages/authentication/login_and_signup_page.dart';
import 'package:ticketapp/pages/error_page.dart';
import 'package:ticketapp/pages/event_details/desktop_view_drawer.dart';
import 'package:ticketapp/repositories/events_repository.dart';
import 'package:ticketapp/repositories/ticket_repository.dart';
import 'package:ticketapp/utilities/alertGenerator.dart';
import '../../UI/theme.dart';
import 'mobile_view.dart';

class EventDetail extends StatefulWidget {
  static const String routeName = '/event';
  final String id;

  const EventDetail({Key key, this.id}) : super(key: key);

  @override
  _EventDetailState createState() => _EventDetailState();
}

class _EventDetailState extends State<EventDetail> with TickerProviderStateMixin {
  AuthenticationBloc signUpBloc;

  final int animationTime = 400;

  bool isLoading = false;
  LinkType linkType;

  @override
  void initState() {
    signUpBloc = AuthenticationBloc();
    getEvent();
    super.initState();
  }

  getEvent() async {
    setState(() => isLoading = true);
    final event = await EventsRepository.instance.loadEventById(widget.id);
    final overviewLinkType = OverviewLinkType(event);
    signUpBloc = AuthenticationBloc();
    signUpBloc.add(EventPageLoad());
    TicketRepository.instance.incrementLinkOpenedCounter(overviewLinkType);

    setState(() {
      linkType = overviewLinkType;
      isLoading = false;
    });
  }

  @override
  void dispose() {
    signUpBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    MyTheme.maxWidth = screenSize.width < 1050 ? screenSize.width : 1050;
    MyTheme.cardPadding = getValueForScreenType(context: context, watch: 8, mobile: 8, tablet: 20, desktop: 20);

    return Scaffold(
      endDrawer: BlocProvider.value(
        value: signUpBloc,
        child: DesktopViewDrawer(
          bloc: signUpBloc,
          linkType: linkType,
        ),
      ),
      endDrawerEnableOpenDragGesture: false,
      body: Builder(builder: (context) {
        if (widget.id == null || widget.id.trim() == '') {
          return ErrorPage('Event Not Found');
        }
        return isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Stack(
                children: [
                  EventDetailBackground(coverImageURL: linkType.event.coverImageURL),
                  Align(
                    alignment: Alignment.topCenter,
                    child: SingleChildScrollView(
                      child: SizedBox(
                        width: screenSize.width,
                        child: Container(
                          constraints: BoxConstraints(maxWidth: MyTheme.maxWidth + 8),
                          child: Padding(
                            padding: EdgeInsets.all(
                                getValueForScreenType(context: context, desktop: 0, tablet: 0, mobile: 8, watch: 8)),
                            child: Column(
                              children: [
                                Column(
                                  children: [
                                    // Add some top padding if we show the appbar
                                    BlocBuilder<AuthenticationBloc, AuthenticationState>(
                                        cubit: signUpBloc,
                                        builder: (c, state) {
                                          return ResponsiveBuilder(builder: (context, constraints) {
                                            if (state is StateLoggedIn &&
                                                (constraints.deviceScreenType == DeviceScreenType.mobile ||
                                                    constraints.deviceScreenType == DeviceScreenType.watch)) {
                                              return SizedBox(height: 66);
                                            } else {
                                              return SizedBox.shrink();
                                            }
                                          });
                                        }),

                                    BlocBuilder<AuthenticationBloc, AuthenticationState>(
                                        cubit: signUpBloc,
                                        builder: (c, state) {
                                          return ResponsiveBuilder(builder: (context, constraints) {
                                            if ((constraints.deviceScreenType == DeviceScreenType.mobile ||
                                                constraints.deviceScreenType == DeviceScreenType.watch)) {
                                              if (state is StateNewUserEmail ||
                                                  state is StateNewUserEmailsConfirmed ||
                                                  state is StatePasswordsConfirmed) {
                                                return SizedBox.shrink();
                                              } else {
                                                return Column(
                                                  children: [
                                                    _buildWhyAreYouHere(state),
                                                    Container(
                                                      child: EventInfoWidget(Axis.vertical, linkType),
                                                    ).appolloCard.paddingBottom(8),
                                                  ],
                                                );
                                              }
                                            } else {
                                              return EventInfoWidget(Axis.horizontal, linkType)
                                                  .paddingTop(MyTheme.cardPadding);
                                            }
                                          });
                                        }),

                                    // Builds the login functionality
                                    BlocConsumer<AuthenticationBloc, AuthenticationState>(
                                        cubit: signUpBloc,
                                        listener: (c, state) {
                                          if (state is StateErrorSignUp) {
                                            String text =
                                                "We couldn't create an account for you, please make sure your password is at least 8 characters long";
                                            if (state.error == SignUpError.UserCancelled) {
                                              text =
                                                  "Login pop up closed. Your browser might be blocking the login pop up. Please try again or use a different login method.";
                                            } else {
                                              text = "An error occurred during the signup process, please try again";
                                            }
                                            AlertGenerator.showAlert(
                                                context: context,
                                                title: "Error",
                                                content: text,
                                                buttonText: "Ok",
                                                popTwice: false);
                                          } else if (state is StateLoginFailed) {
                                            AlertGenerator.showAlert(
                                                context: context,
                                                title: "Wrong Password",
                                                content: "Your password is incorrect, please try again.",
                                                buttonText: "Ok",
                                                popTwice: false);
                                          } else if (state is StateLoggedIn &&
                                              (getDeviceType(screenSize) == DeviceScreenType.mobile ||
                                                  getDeviceType(screenSize) == DeviceScreenType.watch)) {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => EventDetailsPage(
                                                          linkType,
                                                          forwardToPayment: state is StateAutoLoggedIn ? false : true,
                                                        ))).then((value) {
                                              signUpBloc.add(EventPageLoad());
                                            });
                                          }
                                        },
                                        buildWhen: (c, state) {
                                          if (state is StateErrorSignUp) {
                                            return false;
                                          }
                                          return true;
                                        },
                                        builder: (c, state) {
                                          if (state is StateLoggedIn &&
                                                  (getDeviceType(screenSize) == DeviceScreenType.mobile ||
                                                      getDeviceType(screenSize) == DeviceScreenType.watch) ||
                                              (getDeviceType(screenSize) == DeviceScreenType.tablet ||
                                                  getDeviceType(screenSize) == DeviceScreenType.desktop)) {
                                            return SizedBox.shrink();
                                          } else {
                                            return Column(
                                              children: [
                                                AnimatedSize(
                                                  vsync: this,
                                                  duration: Duration(milliseconds: animationTime),
                                                  child: Container(
                                                    constraints: BoxConstraints(maxWidth: MyTheme.maxWidth + 8),
                                                    child: Container(
                                                      child: Padding(
                                                        padding: EdgeInsets.all(MyTheme.cardPadding),
                                                        child: LoginAndSignupPage(
                                                          bloc: signUpBloc,
                                                          textTheme: MyTheme.lightTextTheme,
                                                        ),
                                                      ),
                                                    ).appolloCard,
                                                  ),
                                                ),
                                              ],
                                            )
                                                .paddingTop(getValueForScreenType(
                                                    context: context,
                                                    desktop: MyTheme.elementSpacing,
                                                    tablet: MyTheme.elementSpacing,
                                                    mobile: 0,
                                                    watch: 0))
                                                .paddingBottom(getValueForScreenType(
                                                    context: context,
                                                    desktop: state is StateLoggedIn ? MyTheme.elementSpacing : 0,
                                                    tablet: state is StateLoggedIn ? MyTheme.elementSpacing : 0,
                                                    mobile: 0,
                                                    watch: 0));
                                          }
                                        }),
                                  ],
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                ResponsiveBuilder(builder: (context, constraints) {
                                  if ((constraints.deviceScreenType == DeviceScreenType.mobile ||
                                      constraints.deviceScreenType == DeviceScreenType.watch)) {
                                    return PoweredByAppollo();
                                  } else {
                                    return SizedBox(
                                      height: 60,
                                    );
                                  }
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
      }),
    );
  }

  Widget _buildWhyAreYouHere(AuthenticationState state) {
    if (linkType is AdvertisementInvite || state is StateNewUserEmail || state is StateNewUserEmailsConfirmed) {
      return Container();
    }

    String text = "";

    if (linkType is PromoterInvite) {
      PromoterInvite invitation = linkType;
      text = "${invitation.promoter.firstName} ${invitation.promoter.lastName} has invited you to an event.";
    } else if (linkType is Booking) {
      Booking invitation = linkType;
      text =
          "${invitation.promoter.firstName} ${invitation.promoter.lastName} has invited you to their birthday party.";
    }

    return WhyAreYouHereWidget(text).paddingBottom(8);
  }
}
