import 'package:auto_size_text/auto_size_text.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ticketapp/UI/event_overview/side_buttons.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/appollo/appolloDivider.dart';
import 'package:ticketapp/UI/widgets/buttons/apollo_button.dart';
import 'package:ticketapp/UI/widgets/buttons/card_button.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/pages/event_details/widget/counter.dart';
import 'package:ticketapp/utilities/svg/icon.dart';

import 'detail_with_button.dart';

class EventDetailInfo extends StatelessWidget {
  final Event event;

  const EventDetailInfo({Key key, this.event}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: MyTheme.maxWidth,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _eventImageDays(context),
              _mainBody(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _eventImageDays(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: MediaQuery.of(context).viewPadding.top + 90),
        Container(
          width: MyTheme.maxWidth,
          child: AspectRatio(
            aspectRatio: 1.9,
            child: Card(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(6)),
                child: ExtendedImage.network(event.coverImageURL ?? "", cache: true, fit: BoxFit.cover,
                    loadStateChanged: (ExtendedImageState state) {
                  switch (state.extendedImageLoadState) {
                    case LoadState.loading:
                      return Container(
                        color: Colors.white,
                      );
                    case LoadState.completed:
                      return state.completedWidget;
                    default:
                      return Container(
                        color: Colors.white,
                      );
                  }
                }),
              ),
            ),
          ),
        ),
        SizedBox(height: 14),
        Column(
          children: [
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => SideButton(
                    activeColor: MyTheme.appolloRed,
                    disableColor: MyTheme.appolloWhite,
                    title: 'Sat 12th 2021',
                    isTap: false,
                    onTap: () {},
                  ),
                ),
              ).paddingAll(8),
            ).appolloCard(color: MyTheme.appolloDarkBlue.withAlpha(190)),
            SizedBox(height: MyTheme.cardPadding),
            InkWell(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  color: MyTheme.appolloGrey.withAlpha(80),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_downward, color: MyTheme.appolloGreen, size: 28).paddingAll(4),
              ),
            ),
          ],
        ),
        SizedBox(height: 160),
      ],
    );
  }

  Widget _mainBody(BuildContext context) => Container(
        child: Column(
          children: [
            EventDetailWithButtons(
              event: event,
              buttons: List.generate(
                5,
                (index) => CardButton(
                  title: 'Event Detail',
                  borderRadius: BorderRadius.circular(5),
                  activeColor: MyTheme.appolloGreen,
                  deactiveColor: MyTheme.appolloGrey.withAlpha(140),
                  activeColorText: MyTheme.appolloWhite,
                  deactiveColorText: MyTheme.appolloGreen,
                  onTap: () {},
                ),
              ),
            ),
            _countDown(context),
            _eventDescription(context),
            _preSaleRegistration(context),
          ],
        ).paddingAll(MyTheme.cardPadding),
      ).appolloCard(color: MyTheme.appolloDarkBlue);

  Widget _countDown(context) => Container(
        child: Column(
          children: [
            AutoSizeText('Countdown to Pre-Sale Registration',
                style: Theme.of(context)
                    .textTheme
                    .headline4
                    .copyWith(color: MyTheme.appolloGreen, fontWeight: FontWeight.w600)),
            const SizedBox(height: 30),
            SizedBox(
              width: 450,
              child: Container(
                child: Row(
                  children: [
                    Expanded(child: AppolloCounter(counterType: 'Days')),
                    Expanded(child: AppolloCounter(counterType: 'Hours').paddingHorizontal(8)),
                    Expanded(child: AppolloCounter(counterType: 'Minutes')),
                  ],
                ).paddingAll(MyTheme.cardPadding),
              ).appolloCard(),
            ),
            const SizedBox(height: 30),
            AppolloButton.wideButton(
              heightMax: 40,
              heightMin: 40,
              child: Center(
                child: Text(
                  'REMIND ME',
                  style: Theme.of(context).textTheme.button.copyWith(color: MyTheme.appolloDarkBlue),
                ),
              ),
              onTap: () {},
              color: MyTheme.appolloGreen,
            ),
            const SizedBox(height: 30),
            AppolloDivider(),
          ],
        ),
      );

  Widget _eventDescription(context) => Column(
        children: [
          Column(
            children: [
              AutoSizeText('Event Details',
                  style: Theme.of(context)
                      .textTheme
                      .headline4
                      .copyWith(color: MyTheme.appolloGreen, fontWeight: FontWeight.w600)),
              const SizedBox(height: 30),
              AutoSizeText("${event?.description ?? ''}",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.caption.copyWith(fontWeight: FontWeight.w500)),
            ],
          ).paddingHorizontal(32),
          const SizedBox(height: 30),
          AppolloDivider(),
        ],
      );

  _preSaleRegistration(BuildContext context) => Builder(
        builder: (context) {
          return Column(
            children: [
              Column(
                children: [
                  AutoSizeText('Pre-Sale Registration',
                      style: Theme.of(context)
                          .textTheme
                          .headline4
                          .copyWith(color: MyTheme.appolloGreen, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 30),
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
              const SizedBox(height: 30),
              AppolloButton.wideButton(
                heightMax: 40,
                heightMin: 40,
                child: Center(
                  child: Text(
                    'REGISTER FOR PRE-SALE',
                    style: Theme.of(context).textTheme.button.copyWith(color: MyTheme.appolloDarkBlue),
                  ),
                ),
                onTap: () {},
                color: MyTheme.appolloGreen,
              ),
              const SizedBox(height: 30),
              AutoSizeText('Pre-Sale Perks',
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .copyWith(color: MyTheme.appolloOrange, fontWeight: FontWeight.w600)),
              const SizedBox(height: 30),
              LevalCard(),
            ],
          );
        },
      );
}

class LevalCard extends StatelessWidget {
  const LevalCard({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      width: 300,
      child: Container(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -50,
              left: 15,
              right: 15,
              child: SizedBox(
                height: 700,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SvgPicture.asset(AppolloSvgIcon.level1, height: 80, width: 80).paddingBottom(MyTheme.cardPadding),
                    Column(
                      children: [
                        AutoSizeText('Level 1', style: Theme.of(context).textTheme.bodyText2).paddingBottom(4),
                        AutoSizeText('10 Referrals',
                                style: Theme.of(context).textTheme.bodyText2.copyWith(color: MyTheme.appolloGreen))
                            .paddingBottom(8),
                        AutoSizeText("""Free drink on arrival*
1 x 25% Discounted ticket
+2 Entries in the prize draw""", textAlign: TextAlign.left, style: Theme.of(context).textTheme.bodyText2)
                            .paddingBottom(8),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ).paddingAll(MyTheme.cardPadding),
      ).appolloCard(),
    );
  }
}
