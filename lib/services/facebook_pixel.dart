import 'dart:js' as js;

class FBPixelService {
  static FBPixelService? _instance;

  static FBPixelService get instance {
    if (_instance == null) {
      _instance = FBPixelService._();
    }
    return _instance!;
  }

  FBPixelService._();

  List<String> activePixels = [];

  dispose() {
    activePixels.clear();
  }

  addPixel(String id) {
    try {
      if (!activePixels.contains(id)) {
        activePixels.add(id);
        js.context.callMethod('initPixel', [id]);
      }
    } catch (_) {}
  }

  sendPageViewEvent(String id) {
    try {
      addPixel(id);
      js.context.callMethod('pageView', [id]);
    } catch (_) {}
  }

  sendPurchaseEvent(String id, double value, int quantity, String eventName) {
    try {
      addPixel(id);
      print(value);
      print(quantity);
      print(eventName);
      js.context.callMethod('purchase', [id, value, quantity, eventName]);
    } catch (_) {}
  }
}
