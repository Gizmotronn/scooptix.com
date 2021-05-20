import 'package:auto_size_text/auto_size_text.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ticketapp/UI/event_details/widget/dotpoin.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/buttons/apollo_button.dart';
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
  List<bool> presaleIsExpanded = [];

  @override
  void initState() {
    presaleIsExpanded = List.generate(3, (index) => false);
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
                      Column(
                        children: List.generate(
                          presaleIsExpanded.length,
                          (index) => PreSalePoolCard(
                            radius: BorderRadius.only(
                              topLeft: index == 0 ? Radius.circular(5) : Radius.zero,
                              topRight: index == 0 ? Radius.circular(5) : Radius.zero,
                              bottomLeft: index == presaleIsExpanded.length - 1 ? Radius.circular(5) : Radius.zero,
                              bottomRight: index == presaleIsExpanded.length - 1 ? Radius.circular(5) : Radius.zero,
                            ),
                            isExpanded: presaleIsExpanded[index],
                            ontap: () {
                              if (!presaleIsExpanded[index]) {
                                for (int i = 0; i < presaleIsExpanded.length; i++) {
                                  setState(() {
                                    presaleIsExpanded[i] = false;
                                  });
                                }
                                setState(() {
                                  presaleIsExpanded[index] = true;
                                });
                              } else {
                                setState(() {
                                  presaleIsExpanded[index] = false;
                                });
                              }
                            },
                            title: 'First Place Prize',
                            item: [
                              DotPoint(
                                text: '5 Free Tickets',
                              ),
                              DotPoint(
                                text: '5 Free Tickets',
                              ),
                            ],
                          ),
                        ),
                      ).paddingBottom(MyTheme.elementSpacing),
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

class PreSalePoolCard extends StatefulWidget {
  final String title;
  final List<DotPoint> item;
  final String trailingIcon;
  final bool isExpanded;
  final BorderRadius radius;

  final Function ontap;

  const PreSalePoolCard(
      {Key key, this.title, this.item, this.trailingIcon, this.isExpanded = false, this.radius, this.ontap})
      : super(key: key);

  @override
  _PreSalePoolCardState createState() => _PreSalePoolCardState();
}

class _PreSalePoolCardState extends State<PreSalePoolCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: widget.radius,
        color: widget.isExpanded ? MyTheme.appolloLightCardColor : MyTheme.appolloCardColorLight,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: widget.ontap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.title, style: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.w500)),
                Icon(
                  widget.isExpanded ? Icons.remove : Icons.add,
                  size: 18,
                  color: widget.isExpanded ? MyTheme.appolloOrange : MyTheme.appolloGreen,
                )
              ],
            ).paddingTop(8).paddingBottom(4),
          ),
          AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => SizeTransition(sizeFactor: animation, child: child),
            child: Container(
              key: ValueKey(widget.isExpanded),
              height: widget.isExpanded ? null : 0,
              child: Wrap(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Column(children: widget.item)),
                      widget.trailingIcon == null
                          ? SizedBox.shrink()
                          : SvgPicture.asset(widget.trailingIcon, height: 30),
                    ],
                  ).paddingTop(4).paddingBottom(4)
                ],
              ),
            ),
          )
        ],
      ).paddingHorizontal(8).paddingBottom(4),
    );
  }
}
