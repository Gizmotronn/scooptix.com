import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ticketapp/UI/event_details/widget/counter.dart';
import 'package:ticketapp/main.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/pages/event_details/authentication_drawer.dart';
import 'package:ticketapp/pages/event_details/sections/pre_sales/bloc/pre_sale_bloc.dart';
import 'package:ticketapp/pages/event_details/sections/pre_sales/pre_sale_drawer.dart';
import 'package:ticketapp/repositories/user_repository.dart';

import '../../../../UI/theme.dart';
import '../../../../UI/widgets/appollo/appolloDivider.dart';
import '../../../../UI/widgets/buttons/apollo_button.dart';
import '../../../../UI/widgets/cards/level_card.dart';
import '../../../../utilities/svg/icon.dart';

class PreSaleRegistrationPage extends StatefulWidget {
  final Event event;
  const PreSaleRegistrationPage({Key key, this.event}) : super(key: key);

  @override
  _PreSaleRegistrationPageState createState() => _PreSaleRegistrationPageState();
}

class _PreSaleRegistrationPageState extends State<PreSaleRegistrationPage> {
  PreSaleBloc bloc;

  @override
  void initState() {
    bloc = PreSaleBloc();
    bloc.add(EventCheckStatus(widget.event));
    UserRepository.instance.currentUserNotifier.addListener(() {
      bloc.add(EventCheckStatus(widget.event));
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
    return BlocBuilder<PreSaleBloc, PreSaleState>(
      cubit: bloc,
      builder: (context, state) {
        return Container(
          child: buildPreSale(context, state),
        );
      },
    );
  }

  Widget buildPreSale(BuildContext context, PreSaleState state) {
    if (widget.event.preSale.registrationEndDate.isBefore(DateTime.now())) {
      return SizedBox.shrink();
    } else if (widget.event.preSale.registrationStartDate.isBefore(DateTime.now())) {
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
              style:
                  MyTheme.lightTextTheme.headline2.copyWith(color: MyTheme.appolloGreen, fontWeight: FontWeight.w600),
            ).paddingBottom(32),
            AutoSizeText(
                    "Registering for presale is easy, signup or sign in and we will hold your ticket under your account. You will receive an email when presale tickets have gone on sale.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.caption.copyWith(fontWeight: FontWeight.w500))
                .paddingBottom(8),
            AutoSizeText(
                    "Share your link to unlock extra perks and earn points for each person that signs up for presale, or buys a ticket using your link.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.caption.copyWith(fontWeight: FontWeight.w500))
                .paddingBottom(8),
          ],
        ).paddingHorizontal(32),
        AutoSizeText.rich(
            TextSpan(
              text: 'Check the',
              children: [
                TextSpan(
                    text: ' Prize Pool ',
                    style: Theme.of(context)
                        .textTheme
                        .caption
                        .copyWith(fontWeight: FontWeight.w500, color: MyTheme.appolloOrange)),
                TextSpan(
                    text: 'to see what you could win by sharing your link with friends.',
                    style: Theme.of(context).textTheme.caption.copyWith(fontWeight: FontWeight.w500)),
              ],
            ),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.caption.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 32),
        _subtitle(context, 'Pre-Sale Closes In').paddingBottom(32),
        Countdown(
          width: 280,
          duration: widget.event.date.difference(DateTime.now()),
        ).paddingBottom(32),
        state is StateLoading
            ? Container(child: Center(child: CircularProgressIndicator()).paddingAll(8))
                .appolloTransparentCard(color: MyTheme.appolloBackgroundColorLight.withAlpha(120))
            : state is StateRegistered
                ? InkWell(
                    onTap: () {
                      if (state is StateNotLoggedIn) {
                        WrapperPage.endDrawer.value = AuthenticationDrawer(
                          onAutoAuthenticated: () {
                            bloc.add(EventRegister(widget.event));
                            WrapperPage.endDrawer.value = PreSaleDrawer(
                              bloc: bloc,
                            );
                            WrapperPage.mainScaffold.currentState.openEndDrawer();
                          },
                        );
                        WrapperPage.mainScaffold.currentState.openEndDrawer();
                      } else {
                        bloc.add(EventRegister(widget.event));
                        WrapperPage.endDrawer.value = PreSaleDrawer(
                          bloc: bloc,
                        );
                        WrapperPage.mainScaffold.currentState.openEndDrawer();
                      }
                    },
                    child: Container(
                            child: Text(
                      "You are registered for pre-sale, click for details",
                      style: MyTheme.lightTextTheme.headline6,
                    ).paddingAll(12))
                        .appolloTransparentCard(color: MyTheme.appolloCardColor.withAlpha(120)),
                  )
                : AppolloButton.regularButton(
                    width: 400,
                    child: Center(
                      child: Text(
                        'REGISTER FOR PRE-SALE',
                        style: Theme.of(context).textTheme.button.copyWith(color: MyTheme.appolloBackgroundColor),
                      ),
                    ),
                    onTap: () {
                      if (state is StateNotLoggedIn) {
                        WrapperPage.endDrawer.value = AuthenticationDrawer(
                          onAutoAuthenticated: () {
                            bloc.add(EventRegister(widget.event));
                            WrapperPage.endDrawer.value = PreSaleDrawer(
                              bloc: bloc,
                            );
                            WrapperPage.mainScaffold.currentState.openEndDrawer();
                          },
                        );
                        WrapperPage.mainScaffold.currentState.openEndDrawer();
                      } else {
                        bloc.add(EventRegister(widget.event));
                        WrapperPage.endDrawer.value = PreSaleDrawer(
                          bloc: bloc,
                        );
                        WrapperPage.mainScaffold.currentState.openEndDrawer();
                      }
                    },
                    color: MyTheme.appolloGreen,
                  ),
        _subtitle(context, 'Pre-Sale Perks').paddingTop(32).paddingBottom(60),
        _buildLevel(context).paddingHorizontal(32).paddingBottom(32),
        _subtitle(context, 'Pre-Sale Prize Pool').paddingBottom(60),
        _buildTrophy(context).paddingHorizontal(32).paddingBottom(32),
        AppolloDivider().paddingTop(32),
      ],
    );
  }

  Widget buildPreSaleNotOpenYet() {
    return Column(
      children: [
        AutoSizeText(
          'Countdown to Pre-Sale Registration',
          style: MyTheme.lightTextTheme.headline2.copyWith(color: MyTheme.appolloGreen, fontWeight: FontWeight.w600),
        ).paddingBottom(MyTheme.elementSpacing),
        _buildCountdown().paddingBottom(MyTheme.elementSpacing),
        /* TODO AppolloButton.wideButton(
          heightMax: 40,
          heightMin: 40,
          child: Center(
            child: Text(
              'REMIND ME',
              style: Theme.of(context).textTheme.button.copyWith(color: MyTheme.appolloBackgroundColor),
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
      duration: widget.event.date.difference(DateTime.now()),
    );
  }

  Widget _subtitle(BuildContext context, String title) {
    return AutoSizeText(
      title,
      style: MyTheme.lightTextTheme.headline4.copyWith(color: MyTheme.appolloOrange, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildLevel(BuildContext context) {
    return SizedBox(
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: 3,
        itemBuilder: (context, index) {
          return LevalCard(
            icon: AppolloSvgIcon.level1,
            children: [
              AutoSizeText('Level ${index.toString()}',
                      style: Theme.of(context).textTheme.subtitle1.copyWith(fontWeight: FontWeight.w600))
                  .paddingBottom(4),
              AutoSizeText('10 Referrals',
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1
                          .copyWith(color: MyTheme.appolloGreen, fontWeight: FontWeight.w600))
                  .paddingBottom(8),
              AutoSizeText("""Free drink on arrival*
1 x 25% Discounted ticket
+2 Entries in the prize draw""", textAlign: TextAlign.left, style: Theme.of(context).textTheme.bodyText2)
                  .paddingBottom(8),
            ],
          ).paddingRight(MyTheme.elementSpacing / 2).paddingLeft(MyTheme.elementSpacing / 2);
        },
      ),
    );
  }

  Widget _buildTrophy(BuildContext context) {
    return SizedBox(
      height: 300,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: 3,
          itemBuilder: (context, index) {
            return LevalCard(
              icon: AppolloSvgIcon.trophy1,
              children: [
                AutoSizeText('${(index + 1).toString()}. Place',
                        style: Theme.of(context).textTheme.subtitle1.copyWith(fontWeight: FontWeight.w600))
                    .paddingBottom(4),
                AutoSizeText('Leaderboard',
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1
                            .copyWith(color: MyTheme.appolloGreen, fontWeight: FontWeight.w600))
                    .paddingBottom(8),
                AutoSizeText("""Free drink on arrival*
1 x 25% Discounted ticket
+2 Entries in the prize draw""", textAlign: TextAlign.left, style: Theme.of(context).textTheme.bodyText2)
                    .paddingBottom(8),
              ],
            ).paddingRight(MyTheme.elementSpacing / 2).paddingLeft(MyTheme.elementSpacing / 2);
          }),
    );
  }
}