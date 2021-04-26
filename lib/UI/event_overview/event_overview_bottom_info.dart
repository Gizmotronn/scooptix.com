import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../theme.dart';

class EventOverviewFooter extends StatelessWidget {
  EventOverviewFooter({
    Key key,
  }) : super(key: key);

  final List<List<String>> info = [
    ['How it works', 'Pricing', 'Sell Tickets', 'FAQ', 'Sitemap'],
    ['Loyalty Member App', 'Scanner App', 'For Organisers', 'For large events', 'Event Management'],
    ['Event Planning', 'Why choose appollo', 'Blog', 'Privacy Policy', 'Terms of Service'],
    ['About', 'Help', 'Careers', 'Prices', 'Investors'],
    ['Contact Support', 'Facebook', 'Instagram', 'Twitter', 'LinkedIn'],
  ];
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      width: screenSize.width,
      height: screenSize.height * 0.3,
      color: MyTheme.appolloBlack,
      child: Center(
        child: SizedBox(
            width: screenSize.width * 0.8,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: AutoSizeText('Using Appollo', style: Theme.of(context).textTheme.headline6),
                ).paddingBottom(16).paddingTop(8),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      info.length,
                      (index) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: info[index]
                            .map((text) => AutoSizeText(text,
                                    style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.w400))
                                .paddingVertical(4))
                            .toList(),
                      ),
                    ),
                  ),
                ),
                AutoSizeText(
                    '© 2021 appollo Group pty Ltd. Trademarks and brands are the property of their respective owners.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.caption.copyWith(color: MyTheme.appolloGrey))
              ],
            ).paddingVertical(8)),
      ),
    );
  }
}
