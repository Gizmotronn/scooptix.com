import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme.dart';

class EventOverviewFooter extends StatelessWidget {
  EventOverviewFooter({
    Key? key,
  }) : super(key: key);

  final Map<String, String> info = {
    'How it works': "",
    'Pricing': "",
    'Sell Tickets': "",
    'FAQ': "",
    'Sitemap': "",
    'Loyalty Member App': "https://appollo.io/member",
    'Scanner App': "https://appollo.io/scanner",
    'For Organisers': "https://appollo.io/dashboard",
    'For large events': "",
    'Event Management': "",
    'Event Planning': "",
    'Why choose appollo': "",
    'Blog': "",
    'Privacy Policy': "https://appollo.io/privacy-policy.html",
    'Terms of Service': "https://appollo.io/terms-of-service.html",
    'About': "https://appollo.io",
    'Help': "",
    'Careers': "",
    'Prices': "",
    'Investors': "",
    'Contact Support': "contact@appollo.io",
    'Facebook': "https://www.facebook.com/appolloapps/",
    'Instagram': "https://www.instagram.com/appollo.io/",
    'Twitter': "",
    'LinkedIn': ""
  };

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return ResponsiveBuilder(builder: (context, size) {
      if (size.isTablet || size.isDesktop) {
        return Container(
          width: screenSize.width,
          height: 300,
          color: MyTheme.appolloBlack,
          child: Center(
            child: SizedBox(
                width: screenSize.width * 0.8,
                height: 250,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText('Using ScoopTix', style: Theme.of(context).textTheme.headline6)
                        .paddingBottom(16)
                        .paddingTop(8),
                    SizedBox(
                      height: 140,
                      width: screenSize.width * 0.8,
                      child: Wrap(
                        runSpacing: MyTheme.elementSpacing,
                        runAlignment: WrapAlignment.spaceBetween,
                        direction: Axis.vertical,
                        alignment: WrapAlignment.spaceBetween,
                        children: List.generate(
                            info.length,
                            (index) => InkWell(
                                  onTap: () async {
                                    if (await canLaunch(info[info.keys.toList()[index]]!)) {
                                      await launch(info[info.keys.toList()[index]]!);
                                    }
                                  },
                                  child: AutoSizeText(info.keys.toList()[index],
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2!
                                              .copyWith(fontWeight: FontWeight.w400))
                                      .paddingVertical(4),
                                )),
                      ),
                    ).paddingBottom(MyTheme.elementSpacing),
                    AutoSizeText(
                        '© 2021 ScoopTix Pty Ltd. Trademarks and brands are the property of their respective owners.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.caption!.copyWith(color: MyTheme.appolloGrey))
                  ],
                ).paddingVertical(8)),
          ),
        );
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutoSizeText('Using Appollo', style: Theme.of(context).textTheme.headline6).paddingBottom(16).paddingTop(8),
            SizedBox(
              height: 300,
              width: screenSize.width,
              child: Wrap(
                runSpacing: MyTheme.elementSpacing,
                runAlignment: WrapAlignment.spaceBetween,
                direction: Axis.vertical,
                alignment: WrapAlignment.spaceBetween,
                children: List.generate(
                    info.length,
                    (index) => InkWell(
                          onTap: () async {
                            if (await canLaunch(info[info.keys.toList()[index]]!)) {
                              await launch(info[info.keys.toList()[index]]!);
                            }
                          },
                          child: AutoSizeText(info.keys.toList()[index],
                                  style: Theme.of(context).textTheme.bodyText2!.copyWith(fontWeight: FontWeight.w400))
                              .paddingVertical(4),
                        )),
              ),
            ).paddingBottom(MyTheme.elementSpacing),
            AutoSizeText(
                    '© 2021 appollo Group pty Ltd. Trademarks and brands are the property of their respective owners.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.caption!.copyWith(color: MyTheme.appolloGrey))
                .paddingBottom(MyTheme.elementSpacing)
          ],
        ).paddingLeft(MyTheme.elementSpacing).paddingRight(MyTheme.elementSpacing);
      }
    });
  }
}
