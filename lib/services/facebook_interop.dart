@JS('FB')
library facebook_integration.js;

import 'package:js/js.dart';

typedef FbCallback = void Function(dynamic response);

@JS('init')
external init(InitOptions options);

@JS('api')
external api(String request, FbCallback fn);

@JS('ui')
external ui(LoadUI params, FbCallback fn);

@JS()
@anonymous
class LoadUI {
  external factory LoadUI({
    String method,
    String link,
  });
  external String get method;
  external String get link;
}

@JS()
@anonymous
class InitOptions {
  external factory InitOptions({
    String appId,
    String version,
    bool cookie,
    bool xfbml,
  });
  external String get appId;
  external String get version;
  external bool get cookie;
  external bool get xfbml;
}
