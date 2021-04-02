class RouteData {
  final String route;
  final Map<String, String> _queryParameter;

  RouteData({this.route, Map<String, String> queryParams}) : _queryParameter = queryParams;

  operator [](String key) => _queryParameter[key];
}

extension RouteDataStringExtension on String {
  RouteData get getRouteData {
    var uriData = Uri.parse(this);
    print("Params ${uriData.queryParameters} Path ${uriData.path}");
    return RouteData(queryParams: uriData.queryParameters, route: uriData.path);
  }
}
