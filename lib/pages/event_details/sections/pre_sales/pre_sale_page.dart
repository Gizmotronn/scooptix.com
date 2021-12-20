import 'package:auto_size_text/auto_size_text.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/appollo/appollo_progress_indicator.dart';
import 'package:ticketapp/UI/widgets/buttons/apollo_button.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/pages/event_details/sections/pre_sales/pre_sale_prizes_widget.dart';
import 'package:ticketapp/repositories/user_repository.dart';
import 'package:ticketapp/utilities/platform_detector.dart';
import 'package:ticketapp/UI/icons.dart';

import 'bloc/pre_sale_bloc.dart';

class PreSalePage extends StatelessWidget {
  final PreSaleBloc bloc;
  final Event event;

  const PreSalePage({Key? key, required this.bloc, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PreSaleBloc, PreSaleState>(
      bloc: bloc,
      builder: (c, state) {
        if (state is StatePreSaleNotAvailable) {
          return Center(
            child: Text("Sorry, the Pre-Sale is no longer available"),
          );
        } else if (state is StateRegistered) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (getValueForScreenType(context: context, watch: false, mobile: false, tablet: true, desktop: true))
                AutoSizeText("You're Registered", style: MyTheme.textTheme.headline2)
                    .paddingBottom(MyTheme.elementSpacing),
              AutoSizeText("Hi ${UserRepository.instance.currentUser()!.firstname},",
                      style: MyTheme.textTheme.headline4!.copyWith(color: MyTheme.appolloGreen))
                  .paddingBottom(MyTheme.elementSpacing / 2),
              AutoSizeText(
                      "You have registered for pre-sale. You will be notified once ticket sales start and may also receive special pre-sale offers from the event organiser.")
                  .paddingBottom(MyTheme.elementSpacing),
              if (event.preSale!.hasPrizes)
                AutoSizeText(
                        "Increase your chance of winning by simply sharing your referral code with your friends, family or followers.")
                    .paddingBottom(MyTheme.elementSpacing),
              if (event.preSale!.hasPrizes)
                Container(
                  width: MyTheme.drawerSize,
                  decoration: ShapeDecoration(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AutoSizeText(
                        "Current Points",
                        style: MyTheme.textTheme.headline5!.copyWith(color: MyTheme.appolloGreen),
                      ),
                      AutoSizeText(state.preSale.points.toString())
                    ],
                  ).paddingAll(MyTheme.elementSpacing / 2 + 4),
                ).appolloCard().paddingBottom(MyTheme.elementSpacing * 2),
              AutoSizeText("Referral Link", style: MyTheme.textTheme.headline4!.copyWith(color: MyTheme.appolloOrange))
                  .paddingBottom(MyTheme.elementSpacing),
              OnTapAnimationButton(
                fill: true,
                border: true,
                width: MediaQuery.of(context).size.width,
                onTapColor: MyTheme.appolloGreen,
                suffixIcon: SvgPicture.asset(
                  AppolloIcons.copy,
                  width: 24,
                  height: 24,
                ),
                onTapContent: Text(
                  "LINK COPIED",
                  style: MyTheme.textTheme.headline5,
                ),
                color: MyTheme.appolloBackgroundColor,
                onTap: () {
                  if (PlatformDetector.isMobile()) {
                    Share.share("scooptix.com/?id=${state.preSale.uuid}", subject: 'ScoopTix Event Invitation');
                  } else {
                    FlutterClipboard.copy("scooptix.com/?id=${state.preSale.uuid}");
                  }
                },
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AutoSizeText(
                    "scooptix.com/?id=${state.preSale.uuid}",
                    style: MyTheme.textTheme.bodyText2,
                  ),
                ),
              ).paddingBottom(MyTheme.elementSpacing * 2),
              if (event.preSale!.hasPrizes)
                AutoSizeText("Prize Pool", style: MyTheme.textTheme.headline4!.copyWith(color: MyTheme.appolloOrange))
                    .paddingBottom(MyTheme.elementSpacing),
              if (event.preSale!.hasPrizes) PreSalePrizesWidget(preSale: event.preSale!),
              if (event.preSale!.hasPrizes)
                AutoSizeText(
                        "Winners are drawn at random once pre sale closes, and will be notified by email. Each referral point you earn rewards you with another entry, increasing your odds of winning.")
                    .paddingBottom(MyTheme.elementSpacing),
            ],
          );
        } else {
          return Center(child: AppolloProgressIndicator());
        }
      },
    );
  }
}
