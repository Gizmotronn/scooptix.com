import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:ticketapp/UI/event_details/widget/counter.dart';
import 'package:ticketapp/UI/widgets/appollo/appollo_bottom_sheet.dart';
import 'package:ticketapp/UI/widgets/appollo/appollo_progress_indicator.dart';
import 'package:ticketapp/UI/widgets/cards/appollo_bg_card.dart';
import 'package:ticketapp/main.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/model/pre_sale/pre_sale.dart';
import 'package:ticketapp/pages/authentication/authentication_sheet_wrapper.dart';
import 'package:ticketapp/pages/event_details/mobile/get_tickets_sheet.dart';
import 'package:ui_basics/ui_basics.dart';
import '../../../authentication/authentication_drawer.dart';
import 'package:ticketapp/pages/event_details/sections/pre_sales/bloc/pre_sale_bloc.dart';
import 'package:ticketapp/pages/event_details/sections/pre_sales/pre_sale_drawer.dart';
import 'package:ticketapp/pages/event_details/sections/pre_sales/pre_sale_sheet.dart';
import 'package:ticketapp/repositories/user_repository.dart';

import '../../../../UI/theme.dart';
import '../../../../UI/widgets/appollo/appollo_divider.dart';
import '../../../../UI/widgets/cards/level_card_desktop.dart';
import '../../../../UI/icons.dart';

class PreSaleRegistrationPage extends StatefulWidget {
  final Event event;
  final ScrollController scrollController;
  const PreSaleRegistrationPage({Key? key, required this.event, required this.scrollController}) : super(key: key);

  @override
  _PreSaleRegistrationPageState createState() => _PreSaleRegistrationPageState();
}

class _PreSaleRegistrationPageState extends State<PreSaleRegistrationPage> {
  late PreSaleBloc bloc;
  double position = 0.0;

  @override
  void initState() {
    bloc = PreSaleBloc();
    bloc.add(EventCheckStatus(widget.event));
    UserRepository.instance.currentUserNotifier.addListener(() {
      bloc.add(EventCheckStatus(widget.event));
    });
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (getValueForScreenType(context: context, watch: true, mobile: true, tablet: false, desktop: false) &&
          widget.event.preSaleEnabled &&
          widget.event.preSale!.registrationStartDate.isBefore(DateTime.now()) &&
          widget.event.preSale!.registrationEndDate.isAfter(DateTime.now())) {
        showBottomSheet(
            context: context,
            builder: (c) => QuickAccessSheet(
                  controller: widget.scrollController,
                  mainText: "Register for Pre-Sale",
                  buttonText: "Register",
                  position: position,
                ));
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BoxOffset(
      boxOffset: (offset) {
        if (position == 0.0) {
          setState(() => position = offset.dy);
        }
      },
      child: BlocBuilder<PreSaleBloc, PreSaleState>(
        bloc: bloc,
        builder: (context, state) {
          return Container(
            child: buildPreSale(context, state),
          );
        },
      ),
    );
  }

  Widget buildPreSale(BuildContext context, PreSaleState state) {
    if (widget.event.preSale!.registrationEndDate.isBefore(DateTime.now())) {
      return SizedBox.shrink();
    } else if (widget.event.preSale!.registrationStartDate.isBefore(DateTime.now())) {
      return buildPreSaleOpen(context, state);
    } else {
      return buildPreSaleNotOpenYet();
    }
  }

  Column buildPreSaleOpen(BuildContext context, PreSaleState state) {
    return Column(
      children: [
        Column(
          children: [
            AutoSizeText(
              'Pre-Sale Registration',
              style: MyTheme.textTheme.headline2!.copyWith(color: MyTheme.scoopGreen, fontWeight: FontWeight.w600),
            ).paddingBottom(MyTheme.elementSpacing * 2),
            AutoSizeText(
                    "Sign up for pre-sale alerts and get the chance to purchase tickets before they go on sale to the general public. We will send you a notification when pre-sale tickets go on sale, so you don???t have to worry about missing out.",
                    textAlign: TextAlign.center,
                    style: MyTheme.textTheme.subtitle1)
                .paddingBottom(8),
            if (widget.event.preSale!.hasPrizes)
              AutoSizeText(
                      "Share your link to unlock extra perks and earn points for each person that signs up for presale.",
                      textAlign: TextAlign.center,
                      style: MyTheme.textTheme.subtitle1)
                  .paddingBottom(8),
          ],
        ).paddingHorizontal(MyTheme.elementSpacing),
        if (widget.event.preSale!.hasPrizes)
          AutoSizeText.rich(
                  TextSpan(
                    text: 'Check the',
                    children: [
                      TextSpan(
                          text: ' Prize Pool ',
                          style: MyTheme.textTheme.subtitle1!.copyWith(color: MyTheme.scoopOrange)),
                      TextSpan(
                          text: 'to see what you could win by sharing your link with friends.',
                          style: MyTheme.textTheme.subtitle1),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: MyTheme.textTheme.subtitle1)
              .paddingHorizontal(MyTheme.elementSpacing),
        SizedBox(height: MyTheme.elementSpacing),
        _subtitle(context, 'Pre-Sale Registration Closes In').paddingBottom(MyTheme.elementSpacing),
        Countdown(
          width: 416,
          height: getValueForScreenType(context: context, mobile: 110, watch: 110, tablet: 150, desktop: 150),
          duration: widget.event.preSale!.registrationEndDate.difference(DateTime.now()),
        ).paddingBottom(MyTheme.elementSpacing).paddingHorizontal(MyTheme.elementSpacing),
        state is StateLoading
            ? Container(child: Center(child: AppolloProgressIndicator()).paddingAll(8))
                .appolloCard(color: MyTheme.scoopBackgroundColorLight.withAlpha(120))
            : state is StateRegistered
                ? InkWell(
                    onTap: () {
                      if (getValueForScreenType(
                          context: context, watch: true, mobile: true, tablet: false, desktop: false)) {
                        if (state is StateNotLoggedIn) {
                          showAppolloModalBottomSheet(
                              context: WrapperPage.navigatorKey.currentContext!,
                              backgroundColor: MyTheme.scoopBackgroundColor,
                              expand: true,
                              builder: (context) => AuthenticationPageWrapper(
                                    onAutoAuthenticated: (autoLoggedIn) {
                                      Navigator.pop(WrapperPage.navigatorKey.currentContext!);
                                      bloc.add(EventRegister(widget.event));
                                      PreSaleSheet.openPreSaleSheet(bloc, event: widget.event);
                                    },
                                  ));
                        } else {
                          bloc.add(EventRegister(widget.event));
                          PreSaleSheet.openPreSaleSheet(bloc, event: widget.event);
                        }
                      } else {
                        if (state is StateNotLoggedIn) {
                          WrapperPage.endDrawer.value = AuthenticationDrawer(
                            onAutoAuthenticated: () {
                              bloc.add(EventRegister(widget.event));
                              WrapperPage.endDrawer.value = PreSaleDrawer(
                                bloc: bloc,
                                event: widget.event,
                              );
                              WrapperPage.mainScaffold.currentState!.openEndDrawer();
                            },
                          );
                          WrapperPage.mainScaffold.currentState!.openEndDrawer();
                        } else {
                          bloc.add(EventRegister(widget.event));
                          WrapperPage.endDrawer.value = PreSaleDrawer(
                            bloc: bloc,
                            event: widget.event,
                          );
                          WrapperPage.mainScaffold.currentState!.openEndDrawer();
                        }
                      }
                    },
                    child: Container(
                            child: Text(
                      "You are registered for pre-sale, click for details",
                      style: MyTheme.textTheme.headline6,
                      textAlign: TextAlign.center,
                    ).paddingAll(12))
                        .appolloCard(
                            color: MyTheme.scoopCardColor.withAlpha(120), borderRadius: BorderRadius.circular(16))
                        .paddingHorizontal(MyTheme.elementSpacing),
                  )
                : Padding(
                    padding: EdgeInsets.symmetric(horizontal: MyTheme.elementSpacing),
                    child: ScoopButton(
                      maxWidth: 416,
                      minWidth: 416,
                      title: 'REGISTER FOR PRE-SALE',
                      onTap: () {
                        if (getValueForScreenType(
                            context: context, watch: true, mobile: true, tablet: false, desktop: false)) {
                          if (state is StateNotLoggedIn) {
                            showAppolloModalBottomSheet(
                                context: WrapperPage.navigatorKey.currentContext!,
                                backgroundColor: MyTheme.scoopBackgroundColor,
                                expand: true,
                                builder: (context) => AuthenticationPageWrapper(
                                      onAutoAuthenticated: (autoLoggedIn) {
                                        Navigator.pop(WrapperPage.navigatorKey.currentContext!);
                                        bloc.add(EventRegister(widget.event));
                                        PreSaleSheet.openPreSaleSheet(bloc, event: widget.event);
                                      },
                                    ));
                          } else {
                            bloc.add(EventRegister(widget.event));
                            PreSaleSheet.openPreSaleSheet(bloc, event: widget.event);
                          }
                        } else {
                          if (state is StateNotLoggedIn) {
                            WrapperPage.endDrawer.value = AuthenticationDrawer(
                              onAutoAuthenticated: () {
                                bloc.add(EventRegister(widget.event));
                                WrapperPage.endDrawer.value = PreSaleDrawer(
                                  bloc: bloc,
                                  event: widget.event,
                                );
                                WrapperPage.mainScaffold.currentState!.openEndDrawer();
                              },
                            );
                            WrapperPage.mainScaffold.currentState!.openEndDrawer();
                          } else {
                            bloc.add(EventRegister(widget.event));
                            WrapperPage.endDrawer.value = PreSaleDrawer(
                              bloc: bloc,
                              event: widget.event,
                            );
                            WrapperPage.mainScaffold.currentState!.openEndDrawer();
                          }
                        }
                      },
                      color: MyTheme.scoopGreen,
                    )),
        _buildPrizes(),
        AppolloDivider(),
      ],
    );
  }

  Widget buildPreSaleNotOpenYet() {
    return Column(
      children: [
        AutoSizeText(
          'Countdown to Pre-Sale Registration',
          textAlign: TextAlign.center,
          style: MyTheme.textTheme.headline4!.copyWith(color: MyTheme.scoopGreen, fontWeight: FontWeight.w600),
        ).paddingBottom(MyTheme.elementSpacing),
        _buildCountdown().paddingBottom(MyTheme.elementSpacing),
        /* TODO ScoopButton.wideButton(
          heightMax: 40,
          heightMin: 40,
          child: Center(
            child: Text(
              'REMIND ME',
              style: Theme.of(context).textTheme.button!.copyWith(color: MyTheme.appolloBackgroundColor),
            ),
          ),
          onTap: () {},
          color: MyTheme.appolloGreen,
        ).paddingBottom(MyTheme.elementSpacing),*/
        AppolloDivider(),
      ],
    );
  }

  Widget _buildCountdown() {
    return Countdown(
      width: 432,
      duration: widget.event.preSale!.registrationStartDate.difference(DateTime.now()),
    );
  }

  Widget _subtitle(BuildContext context, String title) {
    return AutoSizeText(
      title,
      style: MyTheme.textTheme.headline4!.copyWith(color: MyTheme.scoopOrange, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildPrize(PreSale preSale) {
    return ResponsiveBuilder(builder: (context, sizes) {
      bool isMobile = sizes.isMobile || sizes.isWatch;
      return SizedBox(
        height: isMobile ? 315 : 330,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: preSale.numPrizes,
            itemBuilder: (context, index) {
              return LevelCard(
                isMobile: isMobile,
                icon: index == 0
                    ? AppolloIcons.trophy1
                    : index == 1
                        ? AppolloIcons.trophy2
                        : AppolloIcons.trophy3,
                children: [
                  AutoSizeText('${(index + 1).toString()}. Place',
                          style: MyTheme.textTheme.headline4!.copyWith(fontWeight: FontWeight.w600))
                      .paddingBottom(MyTheme.elementSpacing / 2),
                  AutoSizeText('Prize Draw',
                          style: MyTheme.textTheme.headline4!
                              .copyWith(color: MyTheme.scoopGreen, fontWeight: FontWeight.w600))
                      .paddingBottom(MyTheme.elementSpacing),
                  AutoSizeText(preSale.activePrizes[index].prizeDescription(),
                          textAlign: TextAlign.center, style: MyTheme.textTheme.subtitle1)
                      .paddingBottom(MyTheme.elementSpacing / 2),
                ],
              ).paddingRight(MyTheme.elementSpacing / 2).paddingLeft(MyTheme.elementSpacing / 2);
            }),
      );
    });
  }

  Widget _buildPrizes() {
    if (!widget.event.preSale!.hasPrizes) {
      return SizedBox.shrink();
    } else {
      return ResponsiveBuilder(builder: (context, size) {
        if (size.isTablet || size.isDesktop) {
          return Column(
            children: [
              SizedBox(
                height: MyTheme.elementSpacing * 2,
              ),
              /*_subtitle(context, 'Pre-Sale Perks')
                  .paddingTop(MyTheme.elementSpacing)
                  .paddingBottom(MyTheme.elementSpacing * 2),
              _buildLevelDesktop(context).paddingBottom(MyTheme.elementSpacing * 2),*/
              _subtitle(context, 'Pre-Sale Prize Pool').paddingBottom(MyTheme.elementSpacing * 2),
              _buildPrize(widget.event.preSale!),
            ],
          );
        } else {
          return Column(
            children: [
              SizedBox(
                height: MyTheme.elementSpacing * 2,
              ),
              /*_subtitle(context, 'Pre-Sale Perks')
                  .paddingTop(MyTheme.elementSpacing)
                  .paddingBottom(MyTheme.elementSpacing * 2),
              _buildLevelMobile(context).paddingBottom(MyTheme.elementSpacing * 2),*/
              _subtitle(context, 'Pre-Sale Prize Pool').paddingBottom(MyTheme.elementSpacing * 2),
              _buildPrize(widget.event.preSale!),
            ],
          );
        }
      });
    }
  }
}
