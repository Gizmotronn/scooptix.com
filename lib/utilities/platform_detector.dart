// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as js;

class PlatformDetector {
  static isMobile() {
    final userAgent = js.window.navigator.userAgent.toString().toLowerCase();
    return userAgent.contains("iphone") || userAgent.contains("android");
  }
}
