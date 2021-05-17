import 'package:auto_size_text/auto_size_text.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/buttons/apollo_button.dart';
import 'package:ticketapp/repositories/user_repository.dart';
import 'package:ticketapp/utilities/platform_detector.dart';

import '../../../../main.dart';
import 'bloc/pre_sale_bloc.dart';

class PreSaleDrawer extends StatelessWidget {
  final PreSaleBloc bloc;

  const PreSaleDrawer({Key key, this.bloc}) : super(key: key);

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
              cubit: bloc,
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
                            AutoSizeText("1")
                          ],
                        ).paddingAll(MyTheme.elementSpacing / 2),
                      ).appolloTransparentCard().paddingBottom(MyTheme.elementSpacing),
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
                          /*  if (PlatformDetector.isMobile()) {
                          Share.share("appollo.io/invite?id=${state.birthdayList.uuid}",
                              subject: 'Appollo Event Invitation');
                        } else {
                          FlutterClipboard.copy("appollo.io/invite?id=${state.birthdayList.uuid}");
                        }*/
                        },
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: AutoSizeText(
                            "appollo.io/invite?id=${1}",
                            style: MyTheme.lightTextTheme.bodyText2,
                          ),
                        ),
                      ).paddingBottom(MyTheme.elementSpacing),
                      AutoSizeText("Prize Pool",
                              style: MyTheme.lightTextTheme.headline4.copyWith(color: MyTheme.appolloOrange))
                          .paddingBottom(MyTheme.elementSpacing),
                      // TODO: Add Prize pool widget
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
