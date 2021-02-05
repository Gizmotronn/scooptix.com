import 'package:flutter/material.dart';
import 'package:flutter_install_app_plugin/flutter_install_app_plugin.dart';
import 'package:webapp/UI/theme.dart';

class DownloadAppolloWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MyTheme.maxWidth,
      height: 100,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("Keep your Invites & Tickets with you"),
            Center(
              child: SizedBox(
                width: MyTheme.maxWidth - 32,
                child: RaisedButton(
                  color: MyTheme.appolloGreen,
                  onPressed: () {
                    var app = AppSet()
                      ..iosAppId = 1478226146
                      ..androidPackageName = 'live.appollo';
                    FlutterInstallAppPlugin.installApp(app);
                  },
                  child: Text("Download the appollo app", style: MyTheme.mainTT.button,),
                ),
              ),
            )
          ],
        ),
      ).appolloCard,
    );
  }
}
