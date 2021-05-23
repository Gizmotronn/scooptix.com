import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ticketapp/UI/event_details/widget/dotpoin.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/model/pre_sale/pre_sale_prize.dart';

class PreSalePrizesWidget extends StatefulWidget {
  final List<PreSalePrize> prizes;

  const PreSalePrizesWidget({Key key, @required this.prizes}) : super(key: key);
  @override
  _PreSalePrizesWidgetState createState() => _PreSalePrizesWidgetState();
}

class _PreSalePrizesWidgetState extends State<PreSalePrizesWidget> {
  List<bool> preSaleIsExpanded = [];

  @override
  void initState() {
    preSaleIsExpanded = List.filled(widget.prizes.length, false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        preSaleIsExpanded.length,
        (index) => PreSalePoolCard(
          radius: BorderRadius.only(
            topLeft: index == 0 ? Radius.circular(5) : Radius.zero,
            topRight: index == 0 ? Radius.circular(5) : Radius.zero,
            bottomLeft: index == preSaleIsExpanded.length - 1 ? Radius.circular(5) : Radius.zero,
            bottomRight: index == preSaleIsExpanded.length - 1 ? Radius.circular(5) : Radius.zero,
          ),
          isExpanded: preSaleIsExpanded[index],
          ontap: () {
            if (!preSaleIsExpanded[index]) {
              for (int i = 0; i < preSaleIsExpanded.length; i++) {
                setState(() {
                  preSaleIsExpanded[i] = false;
                });
              }
              setState(() {
                preSaleIsExpanded[index] = true;
              });
            } else {
              setState(() {
                preSaleIsExpanded[index] = false;
              });
            }
          },
          title: widget.prizes[index].name,
          item:
              List.generate(widget.prizes[index].prizes.length, (i) => DotPoint(text: widget.prizes[index].prizes[i])),
        ),
      ),
    ).paddingBottom(MyTheme.elementSpacing);
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