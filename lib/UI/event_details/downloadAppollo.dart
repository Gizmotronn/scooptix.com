import 'package:flutter/material.dart';
import 'package:flutter_install_app_plugin/flutter_install_app_plugin.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:ticketapp/UI/theme.dart';

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
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: MyTheme.appolloGreen,
                      ),
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
          ).appolloCard(),
        );
      } else {
        return SizedBox(
            width: MyTheme.drawerSize,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Keep your Tickets with you, get the app!",
                  style: MyTheme.lightTextTheme.headline5,
                ).paddingBottom(MyTheme.elementSpacing),
                Text(
                  "Install the appollo app on iOS or Android, sign in the withe same account and keep your tickets with you.",
                  style: MyTheme.lightTextTheme.bodyText2,
                ).paddingBottom(MyTheme.elementSpacing),
              ],
            ));
      }
    });
  }
}
