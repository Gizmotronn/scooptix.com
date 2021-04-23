import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:ticketapp/model/event.dart';

import '../../../UI/theme.dart';
import '../../../UI/widgets/appollo/appolloDivider.dart';
import '../../../UI/widgets/buttons/apollo_button.dart';
import '../../../UI/widgets/cards/level_card.dart';
import '../../../utilities/svg/icon.dart';
import 'counter.dart';
import 'event_title.dart';

class PreSaleRegistration extends StatelessWidget {
  final Event event;
  const PreSaleRegistration({Key key, this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Column(
            children: [
              EventDetailTitle('Pre-Sale Registration').paddingBottom(32),
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
          SizedBox(
            width: 250,
            child: Container(
              child: Row(
                children: [
                  Expanded(
                      child: AppolloSmallCounter(
                          duration: _duration(event?.date ?? DateTime.now()),
                          countDownType:
                              _duration(event.date).inDays <= 1 ? CountDownType.inHours : CountDownType.inDays)),
                  const SizedBox(width: 4),
                  Expanded(
                      child: AppolloSmallCounter(
                          duration: _duration(event.date ?? DateTime.now()),
                          countDownType:
                              _duration(event.date).inDays <= 1 ? CountDownType.inMinutes : CountDownType.inHours)),
                  const SizedBox(width: 4),
                  Expanded(
                      child: AppolloSmallCounter(
                          duration: _duration(event.date ?? DateTime.now()),
                          countDownType: _duration(event.date ?? DateTime.now()).inDays <= 1
                              ? CountDownType.inSeconds
                              : CountDownType.inMinutes)),
                ],
              ).paddingAll(4),
            ).appolloCard(),
          ).paddingBottom(32),
          AppolloButton.wideButton(
            heightMax: 40,
            heightMin: 40,
            child: Center(
              child: Text(
                'REGISTER FOR PRE-SALE',
                style: Theme.of(context).textTheme.button.copyWith(color: MyTheme.appolloBackgroundColor),
              ),
            ),
            onTap: () {},
            color: MyTheme.appolloGreen,
          ),
          _subtitle(context, 'Pre-Sale Perks').paddingTop(32).paddingBottom(60),
          _buildLevel(context).paddingHorizontal(32).paddingBottom(32),
          _subtitle(context, 'Pre-Sale Prize Pool').paddingBottom(60),
          _buildTrophy(context).paddingHorizontal(32).paddingBottom(32),
          AppolloButton.wideButton(
            heightMax: 40,
            heightMin: 40,
            child: Center(
              child: Text(
                'REGISTER FOR PRE-SALE',
                style: Theme.of(context).textTheme.button.copyWith(color: MyTheme.appolloBackgroundColor),
              ),
            ),
            onTap: () {},
            color: MyTheme.appolloGreen,
          ),
          AppolloDivider().paddingTop(32),
        ],
      ),
    );
  }

  Widget _subtitle(BuildContext context, String title) {
    return AutoSizeText(
      title,
      style: Theme.of(context).textTheme.headline3.copyWith(color: MyTheme.appolloOrange, fontWeight: FontWeight.w600),
    );
  }

  Row _buildLevel(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LevalCard(
          icon: AppolloSvgIcon.level1,
          children: [
            AutoSizeText('Level 1', style: Theme.of(context).textTheme.subtitle1.copyWith(fontWeight: FontWeight.w600))
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
        ),
        LevalCard(
          icon: AppolloSvgIcon.level2,
          children: [
            AutoSizeText('Level 1', style: Theme.of(context).textTheme.subtitle1.copyWith(fontWeight: FontWeight.w600))
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
        ).paddingHorizontal(MyTheme.cardPadding),
        LevalCard(
          icon: AppolloSvgIcon.level3,
          children: [
            AutoSizeText('Level 1', style: Theme.of(context).textTheme.subtitle1.copyWith(fontWeight: FontWeight.w600))
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
        ),
      ],
    );
  }

  Row _buildTrophy(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LevalCard(
          icon: AppolloSvgIcon.trophy1,
          children: [
            AutoSizeText('1st Place',
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
        ),
        LevalCard(
          icon: AppolloSvgIcon.trophy2,
          children: [
            AutoSizeText('2nd Place',
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
        ).paddingHorizontal(MyTheme.cardPadding),
        LevalCard(
          icon: AppolloSvgIcon.trophy3,
          children: [
            AutoSizeText('3rd Place',
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
        ),
      ],
    );
  }

  Duration _duration(DateTime time) => time.difference(DateTime.now());
}
