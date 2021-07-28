import 'package:auto_size_text/auto_size_text.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/appollo/appollo_progress_indicator.dart';
import 'package:ticketapp/UI/widgets/buttons/apollo_button.dart';
import 'package:ticketapp/pages/event_details/sections/pre_sales/pre_sale_drawer.dart';
import 'package:ticketapp/pages/event_details/sections/pre_sales/pre_sale_sheet.dart';
import 'package:ticketapp/utilities/format_date/full_date_time.dart';
import 'package:ticketapp/utilities/platform_detector.dart';

import '../../main.dart';
import 'bloc/reward_center_bloc.dart';

class RewardCenterPage extends StatefulWidget {
  @override
  _RewardCenterState createState() => _RewardCenterState();
}

class _RewardCenterState extends State<RewardCenterPage> {
  late RewardCenterBloc bloc;

  @override
  void initState() {
    bloc = RewardCenterBloc();
    bloc.add(EventLoadRewardCenter());
    super.initState();
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return BlocBuilder<RewardCenterBloc, RewardCenterState>(
      bloc: bloc,
      builder: (c, state) {
        if (state is StateRewards) {
          if (state.preSales.length == 0) {
            return Center(
              child: Text(
                "You currently do not have any active competitions or rewards.",
                textAlign: TextAlign.center,
                style: MyTheme.textTheme.bodyText1,
              ),
            );
          }
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Open Competitions",
                  style: getValueForScreenType(
                      context: context,
                      watch: MyTheme.textTheme.headline5!.copyWith(color: MyTheme.appolloGreen),
                      mobile: MyTheme.textTheme.headline5!.copyWith(color: MyTheme.appolloGreen),
                      tablet: MyTheme.textTheme.headline4,
                      desktop: MyTheme.textTheme.headline4),
                ).paddingTop(MyTheme.elementSpacing).paddingBottom(MyTheme.elementSpacing * 2),
                ListView.builder(
                  itemCount: state.preSales.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (c, index) {
                    return Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Competition Closes ${date(state.preSales[index].event!.preSale!.registrationEndDate)}",
                            style: MyTheme.textTheme.caption!.copyWith(color: MyTheme.appolloRed),
                          ).paddingBottom(MyTheme.elementSpacing / 2),
                          Text(
                            state.preSales[index].event!.name,
                            style: MyTheme.textTheme.headline5,
                          ).paddingBottom(MyTheme.elementSpacing * 2),
                          Text("Invitation Link",
                                  style: MyTheme.textTheme.headline5!.copyWith(color: MyTheme.appolloOrange))
                              .paddingBottom(MyTheme.elementSpacing),
                          OnTapAnimationButton(
                            fill: true,
                            border: true,
                            width: screenSize.width,
                            onTapColor: MyTheme.appolloGreen,
                            onTapContent: Text(
                              "LINK COPIED",
                              style: MyTheme.textTheme.headline6,
                            ),
                            color: MyTheme.appolloBackgroundColorLight,
                            onTap: () {
                              if (PlatformDetector.isMobile()) {
                                Share.share("appollo.io/?id=${state.preSales[index].uuid}",
                                    subject: 'Appollo Event Invitation');
                              } else {
                                FlutterClipboard.copy("appollo.io/?id=${state.preSales[index].uuid}");
                              }
                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: AutoSizeText(
                                "appollo.io/?id=${state.preSales[index].uuid}",
                                style: MyTheme.textTheme.bodyText2,
                              ),
                            ),
                          ).paddingBottom(MyTheme.elementSpacing),
                          AppolloButton.regularButton(
                              fill: true,
                              width: MediaQuery.of(context).size.width,
                              color: MyTheme.appolloGreen,
                              child: Text(
                                "View Competition Details",
                                style: MyTheme.textTheme.button,
                              ),
                              onTap: () {
                                if (getValueForScreenType(
                                    context: context, watch: true, mobile: true, tablet: false, desktop: false)) {
                                  PreSaleSheet.openPreSaleSheet(null, event: state.preSales[index].event!);
                                } else {
                                  WrapperPage.endDrawer.value =
                                      PreSaleDrawer(bloc: null, event: state.preSales[index].event!);
                                }
                              })
                        ],
                      ).paddingAll(MyTheme.elementSpacing),
                    ).appolloCard().paddingBottom(MyTheme.elementSpacing);
                  },
                ),
              ],
            ),
          );
        } else {
          return Center(
            child: AppolloProgressIndicator(),
          );
        }
      },
    );
  }
}
