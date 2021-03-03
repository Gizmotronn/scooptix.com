import 'package:flutter/material.dart';
import 'package:flutter_install_app_plugin/flutter_install_app_plugin.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webapp/UI/theme.dart';
import 'package:websafe_svg/websafe_svg.dart';

/// Provides a direct link to the app in the stores
class DownloadAppolloWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, constraints) {
      if (constraints.deviceScreenType == DeviceScreenType.mobile ||
          constraints.deviceScreenType == DeviceScreenType.watch) {
        return SizedBox(
          width: MyTheme.maxWidth,
          height: 100,
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("Keep your Tickets with you, get the app!"),
                Center(
                  child: SizedBox(
                    width: MyTheme.maxWidth - 60,
                    child: RaisedButton(
                      color: MyTheme.appolloGreen,
                      onPressed: () {
                        var app = AppSet()
                          ..iosAppId = 1478226146
                          ..androidPackageName = 'live.appollo';
                        FlutterInstallAppPlugin.installApp(app);
                      },
                      child: Text(
                        "Download the appollo app",
                        style: MyTheme.lightTextTheme.button,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ).appolloCard,
        );
      } else {
        return SizedBox(
            width: MyTheme.drawerSize,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Keep your Tickets with you, get the app!",
                  style: MyTheme.darkTextTheme.headline5,
                ).paddingBottom(MyTheme.elementSpacing),
                Text(
                  "Install the appollo app on iOS or Android, sign in the withe same account and keep your tickets with you.",
                  style: MyTheme.darkTextTheme.bodyText2,
                ).paddingBottom(MyTheme.elementSpacing),
                SizedBox(
                  width: MyTheme.drawerSize,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: MyTheme.drawerSize * 0.3,
                        child: InkWell(
                          onTap: () async {
                            const url = 'https://apps.apple.com/app/appollo/id1478226146#?platform=iphone';
                            if (await canLaunch(url)) {
                              await launch(url);
                            } else {
                              throw 'Could not launch $url';
                            }
                          },
                          child: WebsafeSvg.asset("images/appstore.svg"),
                        ),
                      ),
                      SizedBox(
                        width: MyTheme.drawerSize * 0.3,
                        child: InkWell(
                          onTap: () async {
                            const url = 'https://play.google.com/store/apps/details?id=live.appollo';
                            if (await canLaunch(url)) {
                              await launch(url);
                            } else {
                              throw 'Could not launch $url';
                            }
                          },
                          child: WebsafeSvg.asset("images/playstore.svg"),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ));
      }
    });
  }
}
