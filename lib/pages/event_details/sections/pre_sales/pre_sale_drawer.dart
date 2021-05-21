import 'package:auto_size_text/auto_size_text.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/buttons/apollo_button.dart';
import 'package:ticketapp/model/pre_sale/pre_sale_prize.dart';
import 'package:ticketapp/pages/event_details/sections/pre_sales/pre_sale_prizes_widget.dart';
import 'package:ticketapp/repositories/user_repository.dart';
import 'package:ticketapp/utilities/platform_detector.dart';
import '../../../../main.dart';
import 'bloc/pre_sale_bloc.dart';

class PreSaleDrawer extends StatefulWidget {
  final PreSaleBloc bloc;

  const PreSaleDrawer({Key key, this.bloc}) : super(key: key);

  @override
  _PreSaleDrawerState createState() => _PreSaleDrawerState();
}

class _PreSaleDrawerState extends State<PreSaleDrawer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Container(
      width: MyTheme.drawerSize,
      height: screenSize.height,
      decoration: ShapeDecoration(
          color: MyTheme.appolloBackgroundColorLight,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: () {
                Navigator.pop(WrapperPage.mainScaffold.currentContext);
              },
              child: Icon(
                Icons.close,
                size: 34,
                color: MyTheme.appolloRed,
              ),
            ),
          ).paddingTop(8),
          Expanded(
            child: BlocBuilder(
              cubit: widget.bloc,
              builder: (c, state) {
                if (state is StateRegistered) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText("You're Registered", style: MyTheme.lightTextTheme.headline2)
                          .paddingBottom(MyTheme.elementSpacing),
                      AutoSizeText("Hi ${UserRepository.instance.currentUser().firstname},",
                              style: MyTheme.lightTextTheme.headline4.copyWith(color: MyTheme.appolloGreen))
                          .paddingBottom(MyTheme.elementSpacing / 2),
                      AutoSizeText(
                              "You have registered for pre-sale. You will be notified once ticket sales start and may also receive special pre-sale offers from the event organiser.")
                          .paddingBottom(MyTheme.elementSpacing),
                      AutoSizeText(
                              "Increase your chance of winning by simply sharing your referral code with your friends, family or followers.")
                          .paddingBottom(MyTheme.elementSpacing),
                      Container(
                        width: MyTheme.drawerSize,
                        decoration:
                            ShapeDecoration(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AutoSizeText(
                              "Current Points",
                              style: MyTheme.lightTextTheme.headline6,
                            ),
                            AutoSizeText(state.preSale.points.toString())
                          ],
                        ).paddingAll(MyTheme.elementSpacing / 2),
                      ).appolloTransparentCard().paddingBottom(MyTheme.elementSpacing * 2),
                      AutoSizeText("Referral Link",
                              style: MyTheme.lightTextTheme.headline4.copyWith(color: MyTheme.appolloOrange))
                          .paddingBottom(MyTheme.elementSpacing),
                      OnTapAnimationButton(
                        fill: true,
                        border: true,
                        width: screenSize.width,
                        onTapColor: MyTheme.appolloGreen,
                        onTapContent: Text(
                          "LINK COPIED",
                          style: MyTheme.lightTextTheme.headline6,
                        ),
                        color: MyTheme.appolloCardColor,
                        onTap: () {
                          if (PlatformDetector.isMobile()) {
                            Share.share("appollo.io/invite?id=${state.preSale.uuid}",
                                subject: 'Appollo Event Invitation');
                          } else {
                            FlutterClipboard.copy("appollo.io/invite?id=${state.preSale.uuid}");
                          }
                        },
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: AutoSizeText(
                            "appollo.io/invite?id=${state.preSale.uuid}",
                            style: MyTheme.lightTextTheme.bodyText2,
                          ),
                        ),
                      ).paddingBottom(MyTheme.elementSpacing * 2),
                      AutoSizeText("Prize Pool",
                              style: MyTheme.lightTextTheme.headline4.copyWith(color: MyTheme.appolloOrange))
                          .paddingBottom(MyTheme.elementSpacing),
                      PreSalePrizesWidget(prizes: [
                        PreSalePrize()
                          ..name = "First Prize"
                          ..prizes = ["5 Free Tickets", "\$50 Bar Card"],
                        PreSalePrize()
                          ..name = "Second Prize"
                          ..prizes = ["3 Free Tickets", "\$30 Bar Card"],
                        PreSalePrize()
                          ..name = "Third Prize"
                          ..prizes = ["1 Free Ticket", "\$10 Bar Card"]
                      ]),
                      AutoSizeText(
                              "Winners are drawn at random once pre sale closes, and will be notified by email. Each referral point you earn rewards you with another entry, increasing your odds of winning.")
                          .paddingBottom(MyTheme.elementSpacing),
                    ],
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ).paddingHorizontal(MyTheme.elementSpacing),
    );
  }
}
