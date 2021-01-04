import 'package:flutter/material.dart';
import 'package:webapp/UI/theme.dart';

class AlertGenerator {
  static showAlert(
      {@required BuildContext context,
      @required String title,
      @required String content,
      @required String buttonText,
      @required bool popTwice}) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title, style: MyTheme.mainTT.headline5),
        content: Text(content, style: MyTheme.mainTT.bodyText2),
        actions: <Widget>[
          // usually buttons at the bottom of the dialog
          new FlatButton(
            child: new Text(
              buttonText,
              style: MyTheme.mainTT.bodyText2,
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
        title: Text(title, style: MyTheme.mainTT.headline5),
        content: Text(content, style: MyTheme.mainTT.bodyText2),
        actions: <Widget>[
          // usually buttons at the bottom of the dialog
          FlatButton(
            child: Text(
              buttonText1,
              style: MyTheme.mainTT.bodyText2,
            ),
            onPressed: () {
              response = true;
              Navigator.pop(context);
            },
          ),
          FlatButton(
            child: Text(buttonText2, style: MyTheme.mainTT.bodyText2),
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
