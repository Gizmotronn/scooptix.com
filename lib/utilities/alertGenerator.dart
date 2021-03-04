import 'package:flutter/material.dart';
import 'package:ticketapp/UI/theme.dart';

class AlertGenerator {
  static Future<void> showAlert(
      {@required BuildContext context,
      @required String title,
      @required String content,
      @required String buttonText,
      @required bool popTwice}) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: MyTheme.theme.backgroundColor,
        title: SizedBox(width: MyTheme.maxWidth * 0.8, child: Text(title, style: MyTheme.lightTextTheme.headline5)),
        content: SizedBox(width: MyTheme.maxWidth * 0.8, child: Text(content, style: MyTheme.lightTextTheme.bodyText2)),
        actions: <Widget>[
          // usually buttons at the bottom of the dialog
          new FlatButton(
            child: new Text(
              buttonText,
              style: MyTheme.lightTextTheme.bodyText2,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
    // In some cases, we want to pop the alert as well as the page from which the alert was called from
    if (popTwice) {
      Navigator.pop(context);
    }
  }

  static Future<bool> showAlertWithChoice(
      {@required BuildContext context,
      @required String title,
      @required String content,
      @required String buttonText1,
      @required String buttonText2}) async {
    bool response;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: MyTheme.theme.backgroundColor,
        title: SizedBox(width: MyTheme.maxWidth * 0.8, child: Text(title, style: MyTheme.lightTextTheme.headline5)),
        content: SizedBox(width: MyTheme.maxWidth * 0.8, child: Text(content, style: MyTheme.lightTextTheme.bodyText2)),
        actions: <Widget>[
          // usually buttons at the bottom of the dialog
          FlatButton(
            child: Text(
              buttonText1,
              style: MyTheme.lightTextTheme.subtitle2,
            ),
            onPressed: () {
              response = true;
              Navigator.pop(context);
            },
          ),
          FlatButton(
            child: Text(buttonText2, style: MyTheme.lightTextTheme.bodyText2),
            onPressed: () {
              response = false;
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
    return response;
  }
}
