import 'dart:async';
import 'package:js/js.dart';
import 'file:///C:/Work/Appollo/ticketapp/ticket-app/lib/services/facebook_interop.dart' as fb;

class MessagerShare {
  static Future<void> shareToMessager(String link, String msg) async {
    fb.init(fb.InitOptions(appId: '2581552515272497', version: 'v7.0', cookie: true, xfbml: true));
    fb.ui(
      fb.LoadUI(method: "send", link: link),
      allowInterop(
        (jsResponse) {},
      ),
    );
  }
}
